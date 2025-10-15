//
//  VideoAPIService.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import Foundation

// A mock API service to provide video reel data.
// In a real app, this would make network requests using URLSession or Alamofire.
class VideoAPIService {
    func fetchVideoReels(completion: @escaping (Result<[VideoReel], Error>) -> Void) {
        // Simulate a network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Using publicly available test video URLs with HTTPS to comply with ATS.
            let mockReels: [VideoReel] = [
                .init(id: "1", videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!, description: "A funny bunny adventure"),
                .init(id: "2", videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!, description: "A surreal animated short"),
                .init(id: "3", videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!, description: "Fun with fire!"),
                .init(id: "4", videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!, description: "An amazing escape story"),
                .init(id: "5", videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!, description: "Just having a good time"),
                .init(id: "6", videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4")!, description: "A dramatic meltdown scene"),
            ]
            
            DispatchQueue.main.async {
                completion(.success(mockReels))
            }
        }
    }
}

enum APIError: Error {
    case networkError
}
