//
//  MatchACauseApp.swift
//  MatchACause
//
//  Created by Tashi Bapu on 4/5/25.
//

import SwiftUI

// App theme colors
extension Color {
    static let macPrimary = Color(red: 0.18, green: 0.45, blue: 0.67)
    static let macSecondary = Color(red: 0.96, green: 0.42, blue: 0.27)
    static let macAccent = Color(red: 1.0, green: 0.73, blue: 0.27)
    static let macBackground = Color(red: 0.96, green: 0.98, blue: 1.0)
    static let macSurface = Color.white
    static let macText = Color(red: 0.15, green: 0.2, blue: 0.3)
    static let macTextSecondary = Color(red: 0.45, green: 0.5, blue: 0.55)
    static let macSuccess = Color(red: 0.22, green: 0.74, blue: 0.44)
    static let macError = Color(red: 0.92, green: 0.28, blue: 0.25)
    static let macDivider = Color(red: 0.9, green: 0.91, blue: 0.92)
    static let macCardBackground = Color.white
    static let macTagBackground = Color(red: 0.91, green: 0.95, blue: 1.0)
}

@main
struct MatchACauseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
