//
//  RecipeResponse.swift
//  FetchRecipes
//
//  Created by Leslie Mora Ponce on 2/26/25.
//

// Represent the array of recipes in the response
struct RecipeResponse: Decodable {
    let recipes: [Recipe]
}
