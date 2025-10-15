//
//  AppDelegate.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import UIKit
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure the audio session to allow playback and Picture-in-Picture.
        // This is crucial for media apps. It ensures that app audio continues
        // during silent mode and that PiP is possible.
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        return true
    }
}
