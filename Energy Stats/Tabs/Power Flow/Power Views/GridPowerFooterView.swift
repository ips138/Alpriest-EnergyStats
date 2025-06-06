//
//  GridPowerFooterView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/09/2023.
//

import Energy_Stats_Core
import SwiftUI

struct GridPowerFooterView: View {
    let importTotal: Double?
    let exportTotal: Double?
    let appSettings: AppSettings

    var body: some View {
        if appSettings.showGridTotalsOnPowerFlow {
            AdaptiveStackView {
                VStack {
                    EnergyText(amount: importTotal, appSettings: appSettings, type: .totalImport, decimalPlaceOverride: 1)
                    Text("import_total")
                        .font(.caption)
                        .foregroundColor(Color("text_dimmed"))
                        .accessibilityHidden(true)
                }

                VStack {
                    EnergyText(amount: exportTotal, appSettings: appSettings, type: .totalExport, decimalPlaceOverride: 1)
                    Text("export_total")
                        .font(.caption)
                        .foregroundColor(Color("text_dimmed"))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
        } else {
            VStack {}
        }
    }
}

struct GridPowerFooterView_Previews: PreviewProvider {
    static var previews: some View {
        GridPowerFooterView(
            importTotal: 1.0, exportTotal: 2.0, appSettings: .mock()
        )
    }
}
