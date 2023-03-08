//
//  InverterChoiceView.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/03/2023.
//

import SwiftUI

struct InverterChoiceView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @State private var device: Device?

    var body: some View {
        if viewModel.devices.count > 1 {
            Section(
                content: {
                    Picker("Device to show", selection: $device) {
                        ForEach(viewModel.devices, id: \.deviceID) { device in
                            Text(device.deviceID).tag(device.deviceID)
                        }
                    }
                },
                header: { Text("Inverter") },
                footer: { Text("Selected device and related battery information will be displayed on the main page") }
            )
        }
    }
}

struct InverterChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SettingsTabViewModel(
            userManager: UserManager(networking: DemoNetworking(), store: KeychainStore(), configManager: MockConfigManager()),
            config: MockConfigManager()
        )

        return Form {
            InverterChoiceView(viewModel: viewModel)
        }
    }
}
