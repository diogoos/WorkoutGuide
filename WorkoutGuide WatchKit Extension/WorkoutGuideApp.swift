//
//  WorkoutGuideApp.swift
//  WorkoutGuide WatchKit Extension
//
//  Created by Diogo Silva on 15/07/22.
//

import SwiftUI

@main
struct WorkoutGuideApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
