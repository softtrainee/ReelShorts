//
//  ReelsInteractor.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import Foundation
import Combine

// INTERACTOR
// Contains the core business logic of the module. It communicates with services (API, Cache).
class ReelsInteractor {
    private let apiService: VideoAPIService
    private let cacheManager: VideoCacheManager
    private let downloadManager: DownloadManager

    // Subjects to publish data and errors to the Presenter.
    private let reelsSubject = CurrentValueSubject<[VideoReel], Never>([])
    private let errorSubject = PassthroughSubject<Error, Never>()
    private let downloadStatusSubject = PassthroughSubject<(String, Bool), Never>()
    
    var reelsPublisher: AnyPublisher<[VideoReel], Never> { reelsSubject.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error, Never> { errorSubject.eraseToAnyPublisher() }
    var downloadStatusPublisher: AnyPublisher<(String, Bool), Never> { downloadStatusSubject.eraseToAnyPublisher() }

    init(apiService: VideoAPIService, cacheManager: VideoCacheManager, downloadManager: DownloadManager) {
        self.apiService = apiService
        self.cacheManager = cacheManager
        self.downloadManager = downloadManager
    }

    func fetchReels() {
        apiService.fetchVideoReels { [weak self] result in
            switch result {
            case .success(let reels):
                self?.reelsSubject.send(reels)
            case .failure(let error):
                self?.errorSubject.send(error)
            }
        }
    }
    
    func getVideoURL(for reel: VideoReel, completion: @escaping (URL) -> Void) {
        // First, try to get the URL from the cache.
        if let cachedURL = cacheManager.get(forKey: reel.id) {
            completion(cachedURL)
        } else {
            // If not cached, return the remote URL and start caching it in the background.
            cacheManager.cacheVideo(from: reel.videoURL, forKey: reel.id)
            completion(reel.videoURL)
        }
    }

    func prefetchVideo(for reel: VideoReel) {
        // Start caching the video without blocking the main thread.
        cacheManager.cacheVideo(from: reel.videoURL, forKey: reel.id)
    }

    func downloadVideo(for reel: VideoReel) {
        downloadStatusSubject.send((reel.id, true))
        downloadManager.startDownload(url: reel.videoURL, id: reel.id) { [weak self] result in
            self?.downloadStatusSubject.send((reel.id, false))
            // Handle result (e.g., show completion alert)
        }
    }
}
