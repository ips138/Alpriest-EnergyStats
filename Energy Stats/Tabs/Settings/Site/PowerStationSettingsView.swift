//
//  PowerStationSettingsView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 09/03/2024.
//

import Energy_Stats_Core
import SwiftUI

struct PowerStationSettingsView: View {
    @State var station: PowerStationDetail
    let configManager: ConfigManaging

    var body: some View {
        Form {
            Section {
                ESLabeledText("Name", value: station.stationName)

                ESLabeledText("Capacity", value: station.capacity.w())

                ESLabeledText("Timezone", value: station.timezone)
            }
        }
        .task {
            Task {
                try await configManager.fetchPowerStationDetail()
                if let station = configManager.powerStationDetail {
                    self.station = station
                }
            }
        }
        .navigationTitle(.powerStation)
    }
}

#Preview {
    NavigationView {
        PowerStationSettingsView(
            station: PowerStationDetail(stationName: "station 1", capacity: 5700.0, timezone: "Europe/London"),
            configManager: ConfigManager.preview()
        )
    }
}
