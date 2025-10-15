//
//  ReelsModuleBuilder.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import SwiftUI

// MODULE BUILDER
// Assembles the VIPER module by creating and connecting all its components.
// This is the single entry point for creating the Reels feature.
enum ReelsModuleBuilder {
    static func build() -> some View {
        // Instantiate Services
        let apiService = VideoAPIService()
        let cacheManager = VideoCacheManager()
        let downloadManager = DownloadManager()

        // Instantiate VIPER components
        let interactor = ReelsInteractor(
            apiService: apiService,
            cacheManager: cacheManager,
            downloadManager: downloadManager
        )
        let router = ReelsRouter()
        let presenter = ReelsPresenter(interactor: interactor, router: router)
        
        // The View holds a reference to the Presenter
//        let view = ReelsView(presenter: presenter)
        // Pass the Interactor to the View so it can be forwarded to the player.
        let view = ReelsView(presenter: presenter, interactor: interactor) // <-- CRITICAL CHANGE
                
        return view
    }
    
    /// NEW: Provides an instance of the Interactor for use by sub-views (like VideoPlayerView)
    static func buildInteractor() -> ReelsInteractor {
        return ReelsInteractor(
            apiService: VideoAPIService(),
            cacheManager: VideoCacheManager(),
            downloadManager: DownloadManager()
        )
    }
}
