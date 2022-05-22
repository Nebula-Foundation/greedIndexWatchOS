//
//  greedindexApp.swift
//  greedindex WatchKit Extension
//
//  Created by Ostap Pyrih on 22.05.2022.
//

import SwiftUI

@main
struct greedindexApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
