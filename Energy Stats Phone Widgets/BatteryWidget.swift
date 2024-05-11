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
        let network = NetworkService.standard(keychainStore: keychainStore,
                                              isDemoUser: { false },
                                              dataCeiling: { .none })
        let appSettingsPublisher = AppSettingsPublisherFactory.make(from: config)
        configManager = ConfigManager(networking: network, config: config, appSettingsPublisher: appSettingsPublisher, keychainStore: keychainStore)
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(config: HomeEnergyStateManagerConfigAdapter(config: configManager))) { entry in
            BatteryWidgetView(entry: entry, configManager: configManager)
        }
        .configurationDisplayName("Battery Status Widget")
        .description("Shows the status of your battery storage")
        .supportedFamilies([.accessoryCircular,
                            .accessoryInline,
                            .systemSmall,
                            .systemMedium])
    }
}

struct BatteryWidgetView: View {
    var entry: Provider.Entry
    let configManager: ConfigManaging
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if case let .failedWithoutData(reason) = entry.state {
                switch family {
                case .accessoryCircular:
                    VStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title)

                        Text("No device")
                            .font(.system(size: 8))
                    }.padding(.bottom)
                default:
                    VStack {
                        HStack(alignment: .center) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.red)
                                .font(.title)

                            Text(reason)
                        }.padding(.bottom)

                        Button(intent: UpdateBatteryChargeLevelIntent()) {
                            Text("Tap to retry")
                        }.buttonStyle(.bordered)
                    }
                }
            } else {
                BatteryStatusView(
                    soc: Double(entry.soc ?? 0) / 100.0,
                    chargeStatusDescription: entry.chargeStatusDescription,
                    lastUpdated: entry.date,
                    appSettings: configManager.appSettingsPublisher.value,
                    hasError: entry.errorMessage != nil
                )
            }
        }
        .redacted(reason: entry.state == .placeholder ? [.placeholder] : [])
        .containerBackground(for: .widget) {
            switch entry.state {
            case .failedWithoutData:
                Color.clear
            default:
                if colorScheme == .dark {
                    VStack {
                        Color.clear
                        Color.white.opacity(0.2)
                            .frame(height: footerHeight)
                    }
                } else {
                    VStack {
                        Color.clear
                        Color.paleGray.opacity(0.6)
                            .frame(height: footerHeight)
                    }
                }
            }
        }
        .modelContainer(for: BatteryWidgetState.self)
    }

    var footerHeight: CGFloat {
        switch family {
        case .systemSmall:
            return 32
        default:
            return 38
        }
    }
}

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        BatteryWidgetView(
            entry: SimpleEntry.failed(error: "Something went wrong"),
            configManager: ConfigManager(
                networking: NetworkService.preview(),
                config: MockConfig(),
                appSettingsPublisher: AppSettingsPublisherFactory.make(from: MockConfig()),
                keychainStore: KeychainStore.preview()
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryCircular))

        BatteryWidgetView(
            entry: SimpleEntry.loaded(date: Date(),
                                      soc: 50,
                                      chargeStatusDescription: "Full in 22 minutes",
                                      errorMessage: "Could not refresh",
                                      batteryPower: 0),
            configManager: ConfigManager(
                networking: NetworkService.preview(),
                config: MockConfig(),
                appSettingsPublisher: AppSettingsPublisherFactory.make(from: MockConfig()),
                keychainStore: KeychainStore.preview()
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
