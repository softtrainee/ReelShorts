//
//  ReelsApp.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import SwiftUI

@main
struct ReelsApp: App {
    // By using UIApplicationDelegateAdaptor, we connect our AppDelegate to the SwiftUI app lifecycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            // The ReelsModuleBuilder is responsible for assembling the VIPER module
            // and returning the initial view.
            ReelsModuleBuilder.build()
        }
    }
}
