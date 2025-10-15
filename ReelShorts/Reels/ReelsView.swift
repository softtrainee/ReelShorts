//
//  ReelsView.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import SwiftUI
import AVKit

// VIEW
// The SwiftUI View is responsible for the UI. It's kept "dumb" and forwards all user
// actions to the Presenter. It observes the Presenter for state changes.
struct ReelsView: View {
    // The Presenter is an ObservableObject, so the View will update when its
    // @Published properties change.
    @StateObject var presenter: ReelsPresenter
    // NEW: The interactor is now a dependency passed from the Builder.
        let interactor: ReelsInteractor // <-- NEW PROPERTY
    var body: some View {
        ZStack {
            // The GeometryReader provides the screen dimensions needed for the rotation effect.
            GeometryReader { geometry in
                TabView(selection: $presenter.currentVideoIndex) {
                    ForEach(Array(presenter.reels.enumerated()), id: \.element.id) { index, reel in
                        VideoPlayerView(
                            reel: reel,
                            isPlaying: presenter.currentVideoIndex == index,
                            onDownload: {
                                presenter.downloadButtonTapped(for: reel)
                            },
                            interactor: interactor // <-- PASS THE SINGLETON INSTANCE
                        )
                        // 3. Rotate the content back to its original orientation.
                        .rotationEffect(.degrees(90))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .tag(index)
                        // Inform the presenter when a video appears/disappears to manage playback.
                        .onAppear { presenter.videoAppeared(at: index) }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // 1. Rotate the entire TabView container. This makes horizontal swipes act as vertical ones.
                .rotationEffect(.degrees(-90))
                // 2. The TabView is rotated around its center. We must resize it to fill the screen
                // by swapping the width and height, and then reposition it in the center.
                .frame(width: geometry.size.height, height: geometry.size.width)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)

            if presenter.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .alert(isPresented: $presenter.showError) {
            Alert(
                title: Text("Error"),
                message: Text(presenter.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
