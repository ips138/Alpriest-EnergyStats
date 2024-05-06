//
//  WatchSessionDelegate.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/05/2024.
//

import Energy_Stats_Core
import Foundation
import WatchConnectivity

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    var config: ConfigManaging?

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if case .activated = activationState, let config {
            session.transferUserInfo([
                "batteryCapacity": config.batteryCapacity,
                "shouldInvertCT2": config.shouldInvertCT2,
                "shouldCombineCT2WithPVPower": config.shouldCombineCT2WithPVPower,
                "showUsableBatteryOnly": config.showUsableBatteryOnly
            ])
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {}
}
