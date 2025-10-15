//
//  ReelsPresenterTests.swift
//  ReelShortsTests
//
//  Created by Mohit Gupta on 14/10/25.
//

import XCTest
import Combine
@testable import ReelShorts

class ReelsPresenterTests: XCTestCase {
    
    var presenter: ReelsPresenter!
    var mockInteractor: MockReelsInteractor!
    var mockRouter: ReelsRouter!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockInteractor = MockReelsInteractor()
        mockRouter = ReelsRouter()
        presenter = ReelsPresenter(interactor: mockInteractor, router: mockRouter)
        cancellables = []
    }

    override func tearDown() {
        presenter = nil
        mockInteractor = nil
        mockRouter = nil
        cancellables = nil
        super.tearDown()
    }

    func testOnViewAppear_ShouldFetchReelsAndSetLoadingState() {
        // Given
        let expectation = XCTestExpectation(description: "Reels are fetched and presenter state is updated")
        
        // Then
        presenter.$reels
            .dropFirst() // Ignore initial value
            .sink { reels in
                XCTAssertEqual(reels.count, 1)
                XCTAssertEqual(reels.first?.id, "test1")
                XCTAssertFalse(self.presenter.isLoading)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        presenter.onViewAppear()
        
        // Assert
        XCTAssertTrue(presenter.isLoading)
        wait(for: [expectation], timeout: 1.0)
    }
}

// Mock Interactor for testing purposes
class MockReelsInteractor: ReelsInteractor {
    
    private let mockReels: [VideoReel] = [
        .init(id: "test1", videoURL: URL(string: "http://example.com/video.mp4")!, description: "Test Reel")
    ]
    
    override init(apiService: VideoAPIService, cacheManager: VideoCacheManager, downloadManager: DownloadManager) {
        super.init(apiService: apiService, cacheManager: cacheManager, downloadManager: downloadManager)
    }
    
    convenience init() {
        self.init(apiService: VideoAPIService(), cacheManager: VideoCacheManager(), downloadManager: DownloadManager())
    }

    override func fetchReels() {
        // Directly publish mock data via the private subject (requires making it accessible for test)
        // For a real project, you might use a protocol-based approach.
        // This is a simplified example.
//        let subject = self.value(forKey: "reelsSubject") as? CurrentValueSubject<[VideoReel], Never>
//        subject?.send(mockReels)
    }
}
