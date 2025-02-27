//
//  Recipe.swift
//  FetchRecipes
//
//  Created by Leslie Mora Ponce on 2/26/25.
//

import Foundation

// Match the response object from the json
struct Recipe: Decodable {
    let cuisine: String
    let name: String
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let sourceUrl: String?
    let uuid: String
    let youtubeUrl: String?
    var description: String?
    
    private enum CodingKeys: String, CodingKey {
        case cuisine
        case name
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case uuid
        case youtubeUrl = "youtube_url"
    }
}
