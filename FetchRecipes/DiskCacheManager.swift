//
//  DiskCacheManager.swift
//  FetchRecipes
//
//  Created by Leslie Mora Ponce on 2/26/25.
//


import UIKit

class DiskCacheManager {
    // singleton
    static let shared = DiskCacheManager()
    private let cacheDirectory: URL
    private let fileManager = FileManager.default

    
    
    private init() {
        
        //initialize cache directory if doesn't exist
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        // convert uiimage to data and store it
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
  
    func loadImage(forKey key: String) -> UIImage? {
        // read data and convert to uiimage if exist
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func cacheKey(for url: URL) -> String {
        // because they are all named the same we're using the full url as key
        return url.absoluteString
    }
    
    // await async methods
    
    func saveImage(_ image: UIImage, forKey key: String) async {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard let data = image.pngData() else { return }
        
        do {
            try await Task {
                try data.write(to: fileURL)
            }.value
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func loadImage(forKey key: String) async -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key)

        return await Task {
            if fileManager.fileExists(atPath: fileURL.path),
               let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                return image
            }
            return nil
        }.value
    }
}

