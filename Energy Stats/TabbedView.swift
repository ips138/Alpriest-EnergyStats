//
//  TabbedView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Energy_Stats_Core
import SwiftUI

struct TabbedView: View {
    let configManager: ConfigManager
    let networking: Networking
    let userManager: UserManager
    @StateObject var summaryViewModel: PowerFlowTabViewModel
    @StateObject var graphViewModel: GraphTabViewModel
    @StateObject var settingsTabViewModel: SettingsTabViewModel

    init(networking: Networking, userManager: UserManager, configManager: ConfigManager) {
        self.networking = networking
        self.userManager = userManager
        self.configManager = configManager
        _summaryViewModel = .init(wrappedValue: PowerFlowTabViewModel(networking, configManager: configManager))
        _graphViewModel = .init(wrappedValue: GraphTabViewModel(networking, configManager: configManager))
        _settingsTabViewModel = .init(wrappedValue: SettingsTabViewModel(userManager: userManager, config: configManager))
    }

    var body: some View {
        TabView {
            PowerFlowTabView(viewModel: summaryViewModel, appTheme: configManager.appTheme.value)
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Power flow")
                    }
                    .accessibilityIdentifier("power_flow_tab")
                }

            if #available(iOS 16.0, *) {
                GraphTabView(viewModel: graphViewModel)
                    .tabItem {
                        VStack {
                            Image(systemName: "chart.xyaxis.line")
                            Text("Parameters")
                        }
                        .accessibilityIdentifier("graph_tab")
                    }

                StatsTabView(viewModel: StatsTabViewModel())
                    .tabItem {
                        VStack {
                            Image(systemName: "chart.bar.xaxis")
                            Text("Stats")
                        }
                        .accessibilityIdentifier("graph_tab")
                    }
            }

            SettingsTabView(viewModel: settingsTabViewModel, configManager: configManager)
                .tabItem {
                    VStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .accessibilityIdentifier("settings_tab")
                }
                .if(configManager.isDemoUser) {
                    $0.badge("demo")
                }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct TabbedView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView(networking: DemoNetworking(), userManager:.preview(), configManager: PreviewConfigManager())
    }
}
#endif
