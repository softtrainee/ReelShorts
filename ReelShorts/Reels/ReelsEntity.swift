//
//  ReelsEntity.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import Foundation

// ENTITY
// Represents the core data model for a video reel. It's a simple, plain data structure.
struct VideoReel: Identifiable, Hashable {
    let id: String
    let videoURL: URL
    let description: String
    var isDownloading: Bool = false
}
