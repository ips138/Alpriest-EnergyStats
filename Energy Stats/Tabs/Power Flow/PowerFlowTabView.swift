//
//  PowerFlowTabView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct PowerFlowTabView: View {
    @StateObject private var viewModel: PowerFlowTabViewModel
    @State private var appTheme: AppTheme
    private var appThemePublisher: LatestAppTheme
    @AppStorage("showLastUpdateTimestamp") private var showLastUpdateTimestamp: Bool = false

    init(configManager: ConfigManaging, networking: Networking, appThemePublisher: LatestAppTheme) {
        _viewModel = .init(wrappedValue: PowerFlowTabViewModel(networking, configManager: configManager))
        self.appThemePublisher = appThemePublisher
        self.appTheme = appThemePublisher.value
    }

    var body: some View {
        VStack {
            switch viewModel.state {
            case let .loaded(summary):
                LoadedPowerFlowView(configManager: viewModel.configManager, viewModel: summary, appThemePublisher: appThemePublisher)

                Spacer()

                updateFooterMessage()
            case let .failed(error, reason):
                Spacer()
                ErrorAlertView(cause: error, message: reason) {
                    Task { await viewModel.timerFired() }
                }
                Spacer()
            case .unloaded:
                Spacer()
                HStack(spacing: 8) {
                    Text("Loading")
                    ProgressView()
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(background().edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.viewAppeared()
        }
        .onReceive(appThemePublisher) {
            self.appTheme = $0
        }
    }

    @ViewBuilder func background() -> some View {
        switch appTheme.showSunnyBackground {
        case true:
            backgroundGradient
        case false:
            Color("background")
        }
    }

    @ViewBuilder func updateFooterMessage() -> some View {
        HStack {
            if appTheme.showLastUpdateTimestamp {
                lastUpdateMessage()
                Text(viewModel.updateState)
            } else {
                Group {
                    if showLastUpdateTimestamp {
                        lastUpdateMessage()
                    } else {
                        Text(viewModel.updateState)
                    }
                }.onTapGesture {
                    showLastUpdateTimestamp.toggle()
                }
            }
        }
        .monospacedDigit()
        .font(.caption)
        .foregroundColor(Color("text_dimmed"))
    }

    @ViewBuilder func lastUpdateMessage() -> some View {
        Text("Last update") +
        Text(" ") +
        Text(viewModel.lastUpdated, formatter: DateFormatter.hourMinuteSecond)
    }

    private var backgroundGradient: some View {
        switch viewModel.state {
        case .loaded:
            return LinearGradient(colors: [Color("Sunny"), Color("background")], startPoint: UnitPoint(x: -0.6, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.5))
        case .failed:
            return LinearGradient(colors: [Color.red.opacity(0.7), Color("background")], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        case .unloaded:
            return LinearGradient(colors: [Color.white.opacity(0.5), Color("background")], startPoint: UnitPoint(x: -1.0, y: 0.0), endPoint: UnitPoint(x: 0, y: 0.7))
        }
    }
}

struct PowerFlowTabView_Previews: PreviewProvider {
    static var previews: some View {
        PowerFlowTabView(configManager: PreviewConfigManager(), networking: DemoNetworking(),
                         appThemePublisher: CurrentValueSubject(AppTheme.mock()))
    }
}
