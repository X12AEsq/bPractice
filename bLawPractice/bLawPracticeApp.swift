//
//  bLawPracticeApp.swift
//  bLawPractice
//
//  Created by Morris Albers on 11/17/24.
//

import SwiftUI
import SwiftData

@main
struct bLawPracticeApp: App {
    @StateObject var CVModel = CommonViewModel()
    
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-configure-core-data-to-work-with-swiftui
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SDPractice.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CVModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
