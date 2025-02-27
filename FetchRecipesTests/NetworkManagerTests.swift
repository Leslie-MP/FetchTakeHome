//
//  NetworkManagerTests.swift
//  FetchRecipesTests
//
//  Created by Leslie Mora Ponce on 2/26/25.
//

import XCTest
@testable import FetchRecipes

class NetworkManagerTests: XCTestCase {

    // test success using mock json
    func testFetchRecipesSuccess() {
        let mockJson = """
        {
            "recipes": [
                {
                            "cuisine": "American",
                            "name": "Krispy Kreme Donut",
                            "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/def8c76f-9054-40ff-8021-7f39148ad4b7/large.jpg",
                            "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/def8c76f-9054-40ff-8021-7f39148ad4b7/small.jpg",
                            "source_url": "https://www.mythirtyspot.com/krispy-kreme-copycat-recipe-for/",
                            "uuid": "9e230f96-f93d-4d29-9230-a1f5fd539464",
                            "youtube_url": "https://www.youtube.com/watch?v=SamYg6IUGOI"
                }
            ]
        }
        """.data(using: .utf8)!
        // mock with only the banana pancakes
        let session = MockURLSession(data: mockJson, error: nil)
        let networkManager = NetworkManager(session: session)
        
        let expectation = self.expectation(description: "FetchRecipes")
        
        networkManager.fetchRecipes(from: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json") { result in
            switch result {
            case .success(let recipes):
                XCTAssertEqual(recipes.count, 1)
                XCTAssertEqual(recipes.first?.name, "Banana Pancakes")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, got failure with error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func testFetchRecipesEmptyResponse() {
        let json = "{\"recipes\": []}".data(using: .utf8)!
        
        let session = MockURLSession(data: json, error: nil)
        let networkManager = NetworkManager(session: session)

        let expectation = self.expectation(description: "EmptyFetch")

        networkManager.fetchRecipes(from: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json") { result in
            switch result {
            case .success(let recipes):
                XCTAssertEqual(recipes.count, 0)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected empty response, got failure")
            }
        }
        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testFetchRecipesMalformedJSON() {
        
        let malformedJSON = """
        [
            {"name": "Pasta", "cuisine": "Italian"
        """
        .data(using: .utf8)!
        
        let mockSession = MockURLSession(data: malformedJSON, error: nil)
        let networkManager = NetworkManager(session: mockSession)
        
        let expectation = self.expectation(description: "FetchRecipesMalformedJSON")
        
        networkManager.fetchRecipes(from: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
               
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .dataCorrupted, .keyNotFound, .typeMismatch, .valueNotFound:
                        XCTAssertTrue(true, "Received decoding error as expected")
                    default:
                        XCTFail("Unexpected decoding error")
                    }
                } else {
                    XCTFail("Expected Decoding Error, but got \(error)")
                }
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    /// Async await methods
    ///
    func testAsyncFetchRecipesSuccess() async throws {
        let mockJson = """
        {
            "recipes": [
                {
                    "cuisine": "American",
                    "name": "Krispy Kreme Donut",
                    "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/def8c76f-9054-40ff-8021-7f39148ad4b7/large.jpg",
                    "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/def8c76f-9054-40ff-8021-7f39148ad4b7/small.jpg",
                    "source_url": "https://www.mythirtyspot.com/krispy-kreme-copycat-recipe-for/",
                    "uuid": "9e230f96-f93d-4d29-9230-a1f5fd539464",
                    "youtube_url": "https://www.youtube.com/watch?v=SamYg6IUGOI"
                }
            ]
        }
        """.data(using: .utf8)!

        let session = MockURLSession(data: mockJson, error: nil)
        let networkManager = NetworkManager(session: session)

        let recipes = try await networkManager.fetchRecipes(from: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
        
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.name, "Krispy Kreme Donut")
        
    }
    
    func testAsyncFetchRecipesEmptyResponse() async throws {
            let json = "{\"recipes\": []}".data(using: .utf8)!
            
            let session = MockURLSession(data: json, error: nil)
            let networkManager = NetworkManager(session: session)

            let recipes = try await networkManager.fetchRecipes(from: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")

            XCTAssertEqual(recipes.count, 0)
    }
    
    func testAsyncFetchRecipesMalformedJSON() async {
           let malformedJSON = """
           [
               {"name": "Pasta", "cuisine": "Italian"
           """
           .data(using: .utf8)!
           
           let session = MockURLSession(data: malformedJSON, error: nil)
           let networkManager = NetworkManager(session: session)

        do {
               _ = try await networkManager.fetchRecipes(from: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
               XCTFail("Expected failure, but got success")
           } catch {
               XCTAssertTrue(error is DecodingError, "Expected DecodingError but got \(error)")
           }
       }

}

//Mock class for returning mock data
class MockURLSession: URLSessionProtocol {
    private let data: Data?
    private let error: Error?

    init(data: Data?, error: Error?) {
        self.data = data
        self.error = error
    }

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(data, nil, error)
        // dummy task return
        return URLSession.shared.dataTask(with: url)
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        guard let data = data else {
            throw URLError(.badServerResponse)
        }
        return (data, URLResponse(url: url, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil))
    }

}
