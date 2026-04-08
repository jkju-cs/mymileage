//
//  MotivationRunApp.swift
//  MotivationRun
//

import SwiftUI

@main
struct MotivationRunApp: App {
    init() {
        StoreManager.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
