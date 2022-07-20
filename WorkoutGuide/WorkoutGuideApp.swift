//
//  WorkoutGuideApp.swift
//  WorkoutGuide
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI

@main
struct WorkoutGuideApp: App {
    @StateObject var context = ContextManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(context)
        }
    }
}
