//
//  SolarStringsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 02/03/2024.
//

import Energy_Stats_Core
import SwiftUI

struct MaxWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let nextValue = nextValue()

        guard nextValue > value else { return }

        value = nextValue
    }
}

struct SolarStringsView: View {
    @State var maxLabelWidth: CGFloat = 100
    let viewModel: LoadedPowerFlowViewModel
    let appSettings: AppSettings

    var body: some View {
        if (appSettings.powerFlowStrings.enabled || appSettings.ct2DisplayMode == .asPowerString) && viewModel.displayStrings.count > 0 {
            VStack(alignment: .leading) {
                ForEach(viewModel.displayStrings) { pvString in
                    HStack {
                        Text(pvString.displayName(settings: appSettings.powerFlowStrings))
                            .background(BackgroundSizeReader())
                            .onPreferenceChange(MaxWidthPreferenceKey.self, perform: { value in
                                maxLabelWidth = value
                            })
                            .frame(width: self.maxLabelWidth, alignment: .leading)

                        PowerText(amount: pvString.amount, appSettings: appSettings, type: .solarFlow)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(pvString.displayName(settings: appSettings.powerFlowStrings) + " " + AmountType.solarString.accessibilityLabel(amount: pvString.amount, amountWithUnit: pvString.amount.kWh(2)))
                }
                .foregroundStyle(Color.textNotFlowing)
            }
            .font(.caption)
            .padding(2)
            .background(Color.linesNotFlowing)
        }
    }
}

struct BackgroundSizeReader: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: MaxWidthPreferenceKey.self, value: geometry.size.width)
        }
        .scaledToFill()
    }
}

#Preview {
    let appSettings = AppSettings.mock().copy(powerFlowStrings: PowerFlowStringsSettings.none.copy(enabled: true, pv1Name: "Front", pv2Name: "To"))
    SolarStringsView(
        viewModel: .any(appSettings: appSettings),
        appSettings: appSettings
    )
}
