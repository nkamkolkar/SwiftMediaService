//
//  SwiftMediaClientApp.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/18/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftMediaClientApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            //ContentView()
            LoginView()
        }
        .modelContainer(sharedModelContainer)
    }
}
