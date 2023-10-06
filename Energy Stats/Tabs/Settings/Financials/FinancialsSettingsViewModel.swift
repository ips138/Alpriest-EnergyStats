//
//  FinancialsSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 03/10/2023.
//

import Energy_Stats_Core
import Foundation

class FinancialsSettingsViewModel: ObservableObject {
    @Published var showFinancialSummary: Bool {
        didSet {
            configManager.showFinancialEarnings = showFinancialSummary
        }
    }

    @Published var financialModel: FinancialModel {
        didSet {
            configManager.financialModel = financialModel
        }
    }

    @Published var energyStatsFeedInUnitPrice: String {
        didSet {
            configManager.feedInUnitPrice = Double(energyStatsFeedInUnitPrice) ?? 0.0
        }
    }

    @Published var energyStatsGridImportUnitPrice: String {
        didSet {
            configManager.gridImportUnitPrice = Double(energyStatsGridImportUnitPrice) ?? 0.0
        }
    }

    let currencySymbol: String

    private(set) var configManager: ConfigManaging

    init(configManager: ConfigManaging) {
        self.configManager = configManager
        showFinancialSummary = configManager.showFinancialEarnings
        financialModel = configManager.financialModel
        energyStatsFeedInUnitPrice = configManager.feedInUnitPrice.roundedToString(decimalPlaces: 2)
        energyStatsGridImportUnitPrice = configManager.gridImportUnitPrice.roundedToString(decimalPlaces: 2)
        currencySymbol = configManager.currencySymbol
    }
}
