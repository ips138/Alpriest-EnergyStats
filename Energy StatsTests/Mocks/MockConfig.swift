//
//  MockConfig.swift
//  Energy StatsTests
//
//  Created by Alistair Priest on 26/09/2022.
//

@testable import Energy_Stats
import Energy_Stats_Core
import Foundation

class MockConfig: Config {
    func clear() {}

    var currencySymbol: String = ""
    var shouldCombineCT2WithPVPower: Bool = true
    var showGraphValueDescriptions: Bool = true
    var solcastResourceId: String?
    var solcastApiKey: String?
    var hasRunBefore: Bool = true
    var displayUnit: Int = 0
    var showFinancialEarnings: Bool = true
    var financialModel: Int = 0
    var selectedParameterGraphVariables: [String] = []
    var showHomeTotalOnPowerFlow: Bool = false
    var showInverterIcon: Bool = false
    var shouldInvertCT2: Bool = false
    var showInverterStationName: Bool = false
    var showGridTotalsOnPowerFlow: Bool = false
    var deviceBatteryOverrides: [String: String] = [:]
    var showLastUpdateTimestamp: Bool = false
    var solarDefinitions: SolarRangeDefinitions = .default()
    var parameterGroups: [ParameterGroup] = []
    var feedInUnitPrice: Double = 0.0
    var gridImportUnitPrice: Double = 0.0
    var showTotalYield: Bool = false
    var selfSufficiencyEstimateMode: SelfSufficiencyEstimateMode = .absolute
    var showEarnings: Bool = false
    var showInW: Bool = false
    var isDemoUser: Bool = false
    var showColouredLines: Bool = true
    var showBatteryTemperature: Bool = true
    var refreshFrequency: Int = 0
    var decimalPlaces: Int = 2
    var showSunnyBackground: Bool = true
    var showUsableBatteryOnly: Bool = false
    var showBatteryEstimate: Bool = false
    var devices: Data? = nil
    var selectedDeviceID: String? = "1234"
    var showInverterTemperature: Bool = false
}
