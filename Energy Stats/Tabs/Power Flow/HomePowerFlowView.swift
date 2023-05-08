//
//  PowerSummaryView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import SwiftUI

struct BatterySizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        defaultValue = nextValue()
    }
}

struct HomePowerFlowView: View {
    @State private var iconFooterSize: CGSize = .zero
    @State private var lastUpdated = Date()
    let configManager: ConfigManaging
    let viewModel: HomePowerFlowViewModel
    private let powerViewWidth: CGFloat = 100
    let appTheme: AppTheme

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            SolarPowerView(appTheme: appTheme, viewModel: SolarPowerViewModel(solar: viewModel.solar, generation: viewModel.todaysGeneration))
                .frame(width: powerViewWidth * 2)

            InverterView(viewModel: InverterViewModel(configManager: configManager))
                .frame(height: 2)
                .padding(.horizontal, 14 + powerViewWidth / 2 - 2)
                .padding(.vertical, 1)
                .zIndex(1)

            HStack {
                if viewModel.hasBattery {
                    BatteryPowerView(viewModel: BatteryPowerViewModel(configManager: configManager, batteryStateOfCharge: viewModel.batteryStateOfCharge, batteryChargekWH: viewModel.battery, temperature: viewModel.batteryTemperature), iconFooterSize: $iconFooterSize, appTheme: appTheme)
                        .frame(width: powerViewWidth)

                    Spacer()
                }

                HomePowerView(amount: viewModel.home, iconFooterSize: iconFooterSize, appTheme: appTheme)
                    .frame(width: powerViewWidth)

                Spacer()

                GridPowerView(amount: viewModel.grid, iconFooterSize: iconFooterSize, appTheme: appTheme)
                    .frame(width: powerViewWidth)
            }
            .padding(.horizontal, 14)
        }
    }
}

struct PowerSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        HomePowerFlowView(configManager: PreviewConfigManager(),
                          viewModel: HomePowerFlowViewModel.any(),
                          appTheme: AppTheme.mock())
            .environment(\.locale, .init(identifier: "de"))
    }
}

extension HomePowerFlowViewModel {
    static func any() -> HomePowerFlowViewModel {
        .init(solar: 2.5, battery: -0.01, home: 1.5, grid: 0.71, batteryStateOfCharge: 0.99, hasBattery: true, batteryTemperature: 15.6, todaysGeneration: 8.5)
    }
}

extension AppTheme {
    static func mock() -> AppTheme {
        AppTheme(
            showColouredLines: true,
            showBatteryTemperature: true,
            showSunnyBackground: true,
            decimalPlaces: 3,
            showBatteryEstimate: true,
            showUsableBatteryOnly: false,
            showInW: false
        )
    }
}
