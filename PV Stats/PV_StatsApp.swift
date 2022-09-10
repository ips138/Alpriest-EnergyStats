//
//  PV_StatsApp.swift
//  PV Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import SwiftUI

@main
struct PV_StatsApp: App {
    @ObservedObject var credentials = Credentials()

    var body: some Scene {
        WindowGroup {
            if credentials.hasCredentials {
                TabbedView(networking: Network(credentials: credentials), credentials: credentials)
            } else {
                LoginView(credentials: credentials)
            }
        }
    }
}
