//
//  NetworkManager.swift
//  FetchRecipes
//
//  Created by Leslie Mora Ponce on 2/26/25.
//

import Foundation
import UIKit

// Protocol for easier testing
protocol URLSessionProtocol {
    func dataTask(
        with url: URL,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
    
    func data(from url: URL) async throws -> (Data, URLResponse)
}

// conform to protocol
extension URLSession: URLSessionProtocol {}

class NetworkManager {
    // singleton
    static let shared = NetworkManager()
    
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        
    }
    
    // async method
    func fetchRecipes(from urlString: String) async throws -> [Recipe] {
         guard let url = URL(string: urlString) else {
             throw URLError(.badURL)
         }
         
        let (data, _) = try await session.data(from: url)
         let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
         return recipeResponse.recipes
     }
    
    
    //fetch recipes from URL, returns list of recipe objects or error
    func fetchRecipes(from urlString: String, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            
            //check for errors
            if let error = error {
                completion(.failure(error))
                return
            }
            //check we got data
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                //try to convert data to array of recipes
                let recipeResponse = try JSONDecoder().decode(RecipeResponse.self, from: data)
                completion(.success(recipeResponse.recipes))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //async
    
    func fetchImage(from url: URL) async throws -> UIImage {
        let cacheKey = DiskCacheManager.shared.cacheKey(for: url)
        
        // Return cached image if available
        if let cachedImage = await DiskCacheManager.shared.loadImage(forKey: cacheKey) {
            return cachedImage
        }
    
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw NSError(domain: "Invalid Image Data", code: 0)
        }
        
        // Save to cache
        await DiskCacheManager.shared.saveImage(image, forKey: cacheKey)
        
        return image
    }

    
    // fetch image data from url and caches it
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        let cacheKey = DiskCacheManager.shared.cacheKey(for: url)
         
        //if already cached return that image
        if let cachedImage = DiskCacheManager.shared.loadImage(forKey: cacheKey) {
            completion(.success(cachedImage))
            return
        }
        
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "Invalid Image Data", code: 0)))
                return
            }
            // save in cache
            DiskCacheManager.shared.saveImage(image, forKey: cacheKey)
            
            completion(.success(image))
        }.resume()
    }
}
