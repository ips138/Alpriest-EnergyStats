//
//  ChargeTimePeriod.swift
//  Energy Stats
//
//  Created by Alistair Priest on 26/07/2023.
//

import Foundation
import Energy_Stats_Core

struct ChargeTimePeriod: Equatable {
    var start: Date
    var end: Date
    var enabled: Bool

    init(start: Date? = nil, end: Date? = nil, enabled: Bool) {
        self.start = start ?? .zero()
        self.end = end ?? .zero()
        self.enabled = enabled
    }

    init(startTime: Time, endTime: Time, enabled: Bool) {
        self.init(start: Date.fromTime(startTime), end: Date.fromTime(endTime), enabled: enabled)
    }

    var description: String? {
        if enabled {
            return "Your battery will be charged from \(start.militaryTime()) to \(end.militaryTime())"
        } else {
            return nil
        }
    }

    var validate: String? {
        if start > end {
            return "Start time must be before the end time"
        }

        return nil
    }

    var valid: Bool {
        validate == nil
    }
}

extension Date {
    static func zero() -> Date {
        guard let result = Calendar.current.date(bySetting: .hour, value: 0, of: .now) else { return .now }
        return Calendar.current.date(bySetting: .minute, value: 0, of: result) ?? .now
    }

    static func fromTime(_ time: Time) -> Date {
        guard let result = Calendar.current.date(bySetting: .hour, value: time.hour, of: .now) else { return .now }
        return Calendar.current.date(bySetting: .minute, value: time.minute, of: result) ?? .now
    }
}
