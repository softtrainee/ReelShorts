//
//  ReelsPresenter.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import Foundation
import Combine

// PRESENTER
// Acts as the bridge between the View, Interactor, and Router.
// It formats data from the Interactor for the View and handles user actions.
class ReelsPresenter: ObservableObject {
    private let interactor: ReelsInteractor
    private let router: ReelsRouter
    private var cancellables = Set<AnyCancellable>()

    // @Published properties will trigger UI updates in the SwiftUI View.
    @Published var reels: [VideoReel] = []
    @Published var currentVideoIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    init(interactor: ReelsInteractor, router: ReelsRouter) {
        self.interactor = interactor
        self.router = router

        // Subscribe to updates from the Interactor.
        subscribeToInteractorUpdates()
    }
    
    private func subscribeToInteractorUpdates() {
        // When reels are fetched, update the local state.
        interactor.reelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                self?.reels = $0
            }
            .store(in: &cancellables)
            
        // Handle errors published by the Interactor.
        interactor.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                self?.showError = true
            }
            .store(in: &cancellables)

        // Listen for download status updates
        interactor.downloadStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (reelId, isDownloading) in
                if let index = self?.reels.firstIndex(where: { $0.id == reelId }) {
                    self?.reels[index].isDownloading = isDownloading
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - View Actions
    
    func onViewAppear() {
        isLoading = true
        interactor.fetchReels()
    }

    func videoAppeared(at index: Int) {
        // Pre-fetch next video for smoother playback
        let nextIndex = index + 1
        if nextIndex < reels.count {
            interactor.prefetchVideo(for: reels[nextIndex])
        }
    }

    func downloadButtonTapped(for reel: VideoReel) {
        interactor.downloadVideo(for: reel)
    }
}
