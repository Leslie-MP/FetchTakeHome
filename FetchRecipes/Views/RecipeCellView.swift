//
//  RecipeCellView.swift
//  FetchRecipes
//
//  Created by Leslie Mora Ponce on 2/26/25.
//

import SwiftUI

struct RecipeCellView: View {
    
    private struct Constants {
        static let imageSize = 40.0
        static let cornerRadius: CGFloat = 8
    }
    
    let recipe: Recipe
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    
    var body: some View {
        HStack(spacing: 8) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                } else if isLoading {
                    ProgressView()
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                } else {
                    Color.gray
                        .frame(width: Constants.imageSize, height: Constants.imageSize)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
                }
            }
            
            
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
        }
        .task {
                    await loadImage()
                }

    }
    
    private func loadImage() async {
        guard let photoUrl = recipe.photoUrlSmall, let url = URL(string: photoUrl) else {
            isLoading = false
            return
        }
        
        do {
            image = try await NetworkManager.shared.fetchImage(from: url)
        } catch {
            print("Failed to load image: \(error)")
        }
        isLoading = false
    }
    
}

#Preview {
    RecipeCellView(recipe: Recipe(
        cuisine: "Italian",
        name: "Spaghetti Carbonara",
        photoUrlLarge: nil,
        photoUrlSmall: "https://picsum.photos/200",
        sourceUrl: nil,
        uuid: "123",
        youtubeUrl: nil,
        description: "A classic Italian pasta dish."
    ))
}
