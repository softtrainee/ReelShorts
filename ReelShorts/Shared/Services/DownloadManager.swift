//
//  DownloadManager.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import Foundation

// Manages background downloads using a dedicated URLSession.
class DownloadManager: NSObject, URLSessionDownloadDelegate {
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.example.ReelShorts.background")
        config.isDiscretionary = false // Allows download on cellular
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private var downloadCompletions: [URL: (Result<URL, Error>) -> Void] = [:]

    func startDownload(url: URL, id: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = session.downloadTask(with: url)
        downloadCompletions[url] = completion
        task.resume()
    }
    
    // MARK: - URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        
        let completion = downloadCompletions[sourceURL]
        
        do {
            let documentsPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = documentsPath.appendingPathComponent(sourceURL.lastPathComponent)
            try? FileManager.default.removeItem(at: destinationURL)
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                completion?(.success(destinationURL))
            }
        } catch {
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
        }
        
        downloadCompletions[sourceURL] = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let sourceURL = task.originalRequest?.url, let error = error else { return }
        let completion = downloadCompletions[sourceURL]
        DispatchQueue.main.async {
            completion?(.failure(error))
        }
        downloadCompletions[sourceURL] = nil
    }
}
