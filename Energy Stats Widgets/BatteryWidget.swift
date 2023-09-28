//
//  BatteryWidget.swift
//  WidgetExtension
//
//  Created by Alistair Priest on 15/06/2023.
//

import Energy_Stats_Core
import SwiftUI
import WidgetKit

struct BatteryWidget: Widget {
    let kind: String = "BatteryWidget"
    let configManager: ConfigManaging

    init() {
        let keychainStore = KeychainStore()
        let config = UserDefaultsConfig()
        let store = InMemoryLoggingNetworkStore()
        let network = NetworkFacade(network: Network(credentials: keychainStore, store: store),
                                    config: config,
                                    store: keychainStore)
        configManager = ConfigManager(networking: network, config: config)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BatteryWidgetView(entry: entry, configManager: configManager)
        }
    }
}

struct BatteryWidgetView: View {
    var entry: Provider.Entry
    let configManager: ConfigManaging
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme
    @State private var foo: String = Date.now.iso8601()

    var body: some View {
        Group {
            if case let .failed(reason) = entry.state {
                VStack {
                    Text(reason)
                    Button(intent: UpdateBatteryChargeLevelIntent()) {
                        Text("Tap to retry")
                    }.buttonStyle(.bordered)
                }
            } else {
                BatteryStatusView(
                    soc: Double(entry.soc) / 100.0,
                    chargeStatusDescription: entry.chargeStatusDescription,
                    lastUpdated: entry.date,
                    appTheme: configManager.appTheme.value
                ).redacted(reason: entry.state == .placeholder ? [.placeholder] : [])
            }
        }
        .containerBackground(for: .widget) {
            if colorScheme == .dark {
                Color.white.opacity(0.1)
            } else {
                LinearGradient(colors: [Color.yellow.opacity(0.4), Color.white], startPoint: UnitPoint(x: -0.1, y: 0.0), endPoint: UnitPoint(x: 0, y: 1.0))
            }
        }
        .modelContainer(for: BatteryWidgetState.self)
    }
}

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        BatteryWidgetView(
            entry: SimpleEntry.failed(error: "failed to load data"),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))

        BatteryWidgetView(
            entry: SimpleEntry.loaded(soc: 50, chargeStatusDescription: "Full in 22 minutes"),
            configManager: ConfigManager(networking: DemoNetworking(), config: MockConfig())
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
