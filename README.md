Reel Shorts Application - iOS Assignment
This project is a single-page "Reel Shorts" application for iOS, built with SwiftUI and the VIPER architecture. It is designed to demonstrate performance optimization, memory management, and handling of large media streams as per the assignment requirements.

Core Features Implemented
Vertical Video Feed: A vertically scrollable, page-style feed of video reels, similar to Instagram Reels or YouTube Shorts.

Video Playback: Each reel features a dedicated video player with play, pause, and seek controls. Playback is persistent and automatically handles playing the focused video.

Picture-in-Picture (PiP): Support for PiP is enabled, allowing a video to play in a floating window.

Media Caching: An efficient caching mechanism stores video files for offline playback and faster loading.

Background Downloads: Users can initiate downloads for videos to be viewed offline later. Downloads continue even when the app is in the background.

VIPER Architecture: The application is structured using the VIPER (View, Interactor, Presenter, Entity, Router) design pattern for a clean separation of concerns and improved testability.

Architecture: VIPER
VIPER is a clean architecture pattern that divides an application's logic into distinct layers of responsibility.

View: The ReelsView (SwiftUI View). It is responsible for displaying the UI and relaying user events to the Presenter. It is passive and holds no business logic.

Interactor: The ReelsInteractor. It contains the core business logic, such as fetching video data from an API, managing the video cache, and handling download requests.

Presenter: The ReelsPresenter. It acts as the "middle-man," receiving data from the Interactor, formatting it into a displayable format for the View, and handling user inputs.

Entity: The VideoReel struct. A plain data model that represents the video objects.

Router: The ReelsRouter. It handles navigation logic. While this is a single-page app, the Router is included to demonstrate the complete architecture and could be used for presenting alerts or other views.

This separation makes the codebase modular, easier to maintain, and highly testable.

Caching Strategy Justification
Strategy: Least Recently Used (LRU) with a fixed disk capacity.

How it Works: The VideoCacheManager maintains a cache of video files on the device's disk. When a video is requested for playback, the manager first checks if a cached version exists.

Cache Hit: If the video is in the cache, the local file URL is returned immediately, providing instant playback and offline support. The video is marked as "recently used."

Cache Miss: If the video is not in the cache, it is streamed from the network. Simultaneously, the data is downloaded and stored in the cache for future use.

Eviction Policy: To prevent the cache from growing indefinitely, a maximum size limit (e.g., 200MB) is set. When this limit is exceeded, the least recently used video files are automatically deleted to make space for new ones.

Why LRU?: This strategy is ideal for a reels feed because users are most likely to re-watch recent videos or scroll back a short distance. By keeping the most recently viewed items, we maximize the probability of a cache hit, improving user experience and reducing data consumption. It strikes a balance between performance and storage efficiency.

Project Structure
The project is organized into modules for clarity:

ReelShorts/
|
├── App/
|   ├── ReelsApp.swift           # Main app entry point
|   └── AppDelegate.swift        # App delegate for background tasks & audio setup
|
├── Reels/ (VIPER Module)
|   ├── ReelsView.swift          # SwiftUI View
|   ├── ReelsPresenter.swift     # Presenter
|   ├── ReelsInteractor.swift    # Interactor
|   ├── ReelsRouter.swift        # Router
|   ├── ReelsEntity.swift        # Data Model
|   └── ReelsModuleBuilder.swift # Module assembler
|
├── Shared/
|   ├── Services/
|   |   ├── VideoAPIService.swift  # Fetches video data (mock)
|   |   ├── VideoCacheManager.swift # Handles video caching
|   |   └── DownloadManager.swift   # Manages background downloads
|   |
|   └── Views/
|       └── VideoPlayerView.swift  # Reusable video player component
|
└── Tests/
    └── ReelsPresenterTests.swift  # Unit tests

How to Run
Open the project in Xcode (version 13.2.1 or later).

Enable the "Background Modes" capability in Signing & Capabilities, and check "Audio, AirPlay, and Picture in Picture" and "Background Fetch".

Build and run on a physical iOS device or simulator.

# Output: 

https://youtube.com/shorts/Vb5RPVGQ0GQ?feature=share
