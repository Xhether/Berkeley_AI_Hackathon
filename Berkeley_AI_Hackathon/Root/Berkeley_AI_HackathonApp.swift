//
//  Berkeley_AI_HackathonApp.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

@main

struct Berkeley_AI_HackathonApp: App {
    @StateObject private var configsViewModel = ConfigurationsViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(configsViewModel)
        }
    }
}
