//
//  ClearCalcApp.swift
//  ClearCalc
//
//  Created by Amol Vyavaharkar on 07/04/25.
//

import SwiftUI // 🔥 This was missing!

@main
struct ClearCalcApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
