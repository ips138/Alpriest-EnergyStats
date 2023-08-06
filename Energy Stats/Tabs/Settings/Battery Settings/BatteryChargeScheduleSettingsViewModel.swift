//
//  BatteryChargeScheduleSettingsViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 27/07/2023.
//

import Combine
import Energy_Stats_Core
import Foundation

class BatteryChargeScheduleSettingsViewModel: ObservableObject {
    private let networking: Networking
    private let config: ConfigManaging
    @Published var state: LoadState = .inactive
    @Published var timePeriod1: ChargeTimePeriod = .init(start: Date(), end: Date(), enabled: false)
    @Published var timePeriod2: ChargeTimePeriod = .init(start: Date(), end: Date(), enabled: false)
    @Published var summary = ""
    private var cancellable: AnyCancellable?

    init(networking: Networking, config: ConfigManaging) {
        self.networking = networking
        self.config = config

        load()

        cancellable = Publishers.Zip($timePeriod1, $timePeriod2)
            .sink { [weak self] p1, p2 in
                self?.generateSummary(period1: p1, period2: p2)
            }
    }

    func load() {
        Task { @MainActor in
            guard state == .inactive else { return }
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active(String(key: .loading))

            do {
                let settings = try await networking.fetchBatteryTimes(deviceSN: deviceSN)
                if let first = settings.times[safe: 0] {
                    timePeriod1 = ChargeTimePeriod(startTime: first.startTime, endTime: first.endTime, enabled: first.enableGrid)
                }

                if let second = settings.times[safe: 1] {
                    timePeriod2 = ChargeTimePeriod(startTime: second.startTime, endTime: second.endTime, enabled: second.enableGrid)
                }

                state = .inactive
            } catch {
                state = .error(error, "Could not load settings")
            }
        }
    }

    func save() {
        Task { @MainActor in
            guard let deviceSN = config.currentDevice.value?.deviceSN else { return }
            state = .active("Saving...")

            do {
                let times: [ChargeTime] = [
                    timePeriod1.asChargeTime(),
                    timePeriod2.asChargeTime()
                ]

                try await networking.setBatteryTimes(deviceSN: deviceSN, times: times)
                state = .inactive
            } catch {
                state = .error(error, "Could not save settings")
            }
        }
    }

    func reset() {
        timePeriod1 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
        timePeriod2 = ChargeTimePeriod(start: .zero(), end: .zero(), enabled: false)
    }

    func generateSummary(period1: ChargeTimePeriod, period2: ChargeTimePeriod) {
        var result = ""

        if !period1.enabled && !period2.enabled {
            if period1.hasTimes && period2.hasTimes {
                result = String(format: String(key: .bothBatteryFreezePeriods), period1.description, period2.description)
            } else if period1.hasTimes {
                result = String(format: String(key: .oneBatteryFreezePeriod), period1.description)
            } else if period2.hasTimes {
                result = String(format: String(key: .oneBatteryFreezePeriod), period2.description)
            } else {
                result = String(key: .noBatteryCharge)
            }
        } else if period1.enabled && period2.enabled {
            result = String(format: String(key: .bothBatteryChargePeriods), period1.description, period2.description)

            if period1.overlaps(period2) {
                result += String(key: .batteryPeriodsOverlap)
            }
        } else if period1.enabled {
            result = String(format: String(key: .oneBatteryChargePeriod), period1.description)
        } else if period2.enabled {
            result = String(format: String(key: .oneBatteryChargePeriod), period2.description)
        }

        summary = result
    }
}
