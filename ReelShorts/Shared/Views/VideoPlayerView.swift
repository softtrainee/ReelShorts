//
//  VideoPlayerView.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import SwiftUI
import AVKit

// A custom UIViewRepresentable to host the AVPlayerLayer, giving us full control
// over the video playback view without any default system controls.
struct CustomVideoPlayerView: UIViewRepresentable {
    var player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        // A simple UIView to host our player layer.
        let view = UIView(frame: .zero)
        let playerLayer = AVPlayerLayer(player: player)
        
        // Ensure the video fills the available space, preserving aspect ratio.
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        // The coordinator will handle resizing the layer when the view's bounds change.
        context.coordinator.observeLayerBounds(for: view)
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // This function is called when the view updates.
        // We can ensure the correct player instance is being used.
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.player = player
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // The Coordinator acts as a delegate and helps manage the state of the UIView.
    class Coordinator: NSObject {
        private var observation: NSKeyValueObservation?

        // This method sets up an observer to watch for changes in the view's bounds
        // and updates the player layer's frame accordingly. This is crucial for
        // handling rotations and layout changes correctly.
        func observeLayerBounds(for view: UIView) {
            observation = view.layer.observe(\.bounds, options: [.new]) { layer, _ in
                if let playerLayer = layer.sublayers?.first as? AVPlayerLayer {
                    playerLayer.frame = layer.bounds
                }
            }
        }
        
        deinit {
            // Clean up the observer when the coordinator is deallocated.
            observation?.invalidate()
        }
    }
}


// A reusable SwiftUI View for playing a single video reel.
// It includes player controls and support for Picture-in-Picture.
struct VideoPlayerView: View {
    let reel: VideoReel
    let isPlaying: Bool
    let onDownload: () -> Void
    let interactor: ReelsInteractor // <-- NEW PROPERTY
    
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var timeObserver: Any?
    @State private var progress: Double = 0.0
    @State private var isPlayerPaused: Bool = true
    @State private var pipController: AVPictureInPictureController?
    // NEW: State for the AVPlayerItem status observer
    @State private var itemStatusObserver: AVPlayerItemStatusObserver?

    var body: some View {
        ZStack {
            if let player = player {
                // We now use our CustomVideoPlayerView instead of the default VideoPlayer.
                // This prevents the default system controls from appearing.
                CustomVideoPlayerView(player: player)
                    .overlay(
                        playerControls
                    )
                    .onTapGesture {
                        isPlayerPaused.toggle()
                    }
            } else {
                ProgressView().tint(.white)
            }
        }
        .onAppear(perform: setupPlayer)
        .onDisappear(perform: cleanupPlayer)
        .onChange(of: isPlaying) { newIsPlaying in
            // Handle play/pause logic for when the view becomes the active reel
            if newIsPlaying {
                // Only try to play if the player item is ready
                if playerItem?.status == .readyToPlay {
                    player?.play()
                    isPlayerPaused = false
                }
                // If not ready, the ItemStatusObserver will handle playback start.
            } else {
                player?.pause()
                isPlayerPaused = true
            }
        }
        .onChange(of: isPlayerPaused) { paused in
            if paused { player?.pause() } else { player?.play() }
        }
    }
    
    private var playerControls: some View {
        VStack {
            Spacer()
            // Seek Bar
            Slider(value: $progress, in: 0...1) { editing in
                guard let item = playerItem else { return }
                let duration = item.duration.seconds
                if !editing {
                    let targetTime = CMTime(seconds: progress * duration, preferredTimescale: 600)
                    player?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            }
            .tint(.white)
            
            // Buttons
            HStack {
                Button(action: { isPlayerPaused.toggle() }) {
                    Image(systemName: isPlayerPaused ? "play.fill" : "pause.fill")
                }
                
                Button(action: onDownload) {
                    Image(systemName: reel.isDownloading ? "arrow.down.circle.fill" : "arrow.down.to.line.compact")
                }
                .disabled(reel.isDownloading)

                Button(action: { pipController?.startPictureInPicture() }) {
                    Image(systemName: "pip.enter")
                }
            }
            .font(.title)
            .foregroundColor(.white)
            .padding()
        }
        .padding()
    }
    
    private func setupPlayer() {
        // FIX: Now calls the static buildInteractor() from the updated ReelsModuleBuilder
//        let interactor = ReelsModuleBuilder.buildInteractor()
        interactor.getVideoURL(for: reel) { url in
            let newItem = AVPlayerItem(url: url)
            playerItem = newItem
            player = AVPlayer(playerItem: newItem)
            player?.isMuted = false // Set to true for silent autoplay
            
            // NEW: Set up the status observer to start playback when video data is ready
            itemStatusObserver = AVPlayerItemStatusObserver(item: newItem) { status in
                if status == .readyToPlay, isPlaying {
                    // Start playing only when the item is ready AND this view is the active reel
                    player?.play()
                    isPlayerPaused = false
                }
            }
            
            // Setup PiP
            if AVPictureInPictureController.isPictureInPictureSupported() {
                // We need a player layer to attach the PiP controller to.
                // It can be hidden.
                let playerLayer = AVPlayerLayer(player: player)
                pipController = AVPictureInPictureController(playerLayer: playerLayer)
            }

            // Time observer for seek bar
            timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
                guard let duration = playerItem?.duration.seconds, duration > 0 else { return }
                progress = time.seconds / duration
            }
            
            // Add observer to loop the video
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
                player?.seek(to: CMTime.zero)
                player?.play()
            }
        }
    }
    
    private func cleanupPlayer() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        // Clean up the status observer
        itemStatusObserver = nil
        player = nil
        playerItem = nil
        pipController = nil
    }
}

// A dedicated class to observe the AVPlayerItem's status using KVO
// This ensures playback starts exactly when the asset is ready.
final class AVPlayerItemStatusObserver: NSObject {
    private var item: AVPlayerItem
    private var callback: (AVPlayerItem.Status) -> Void

    init(item: AVPlayerItem, callback: @escaping (AVPlayerItem.Status) -> Void) {
        self.item = item
        self.callback = callback
        super.init()
        // Start observing the 'status' key path
        item.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
    }

    // KVO method override to handle status changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let item = object as? AVPlayerItem {
            // Call the handler with the new status
            callback(item.status)
        } else {
            // Be sure to call the superclass's implementation
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // IMPORTANT: Remove the observer when the object is deallocated
    deinit {
        item.removeObserver(self, forKeyPath: "status")
    }
}
