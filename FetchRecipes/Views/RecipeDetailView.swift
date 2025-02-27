//
//  RecipeDetailView.swift
//  FetchRecipes
//
//  Created by Leslie Mora Ponce on 2/26/25.
//

import SwiftUI


struct RecipeDetailView: View {
    let recipe: Recipe
    
    private struct Constants {
        static let imageSize = 224.0
        
    }
    
    @State private var image: UIImage? = nil
    @State private var isLoading = true
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Recipe Image
                
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else if isLoading {
                        ProgressView()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                    } else {
                        Image("placeholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.top, 24)
                
                // Recipe Name
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Cuisine Type
                Text("Cuisine: \(recipe.cuisine)")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                // Description
                Text(recipe.description ?? "No description available.")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                
                // Buttons
                VStack(spacing: 16) {
                    if let sourceUrl = recipe.sourceUrl, let url = URL(string: sourceUrl) {
                        Link("Website", destination: url)
                            .buttonStyle(PrimaryButtonStyle())
                    }
                    
                    if let youtubeUrl = recipe.youtubeUrl, let url = URL(string: youtubeUrl) {
                        Link("YouTube", destination: url)
                            .buttonStyle(PrimaryButtonStyle())
                        
                    }
                }
                .padding(.top, 16)
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .task {
                    await loadImage()
                }
    }
    
    private func loadImage() async {
        guard let photoUrl = recipe.photoUrlLarge, let url = URL(string: photoUrl) else {
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

// Custom Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.horizontal, 24)
    }
}

// Preview
#Preview {
    RecipeDetailView(recipe: Recipe(
        cuisine: "Italian",
        name: "Spaghetti Carbonara",
        photoUrlLarge: "https://via.placeholder.com/300x200",
        photoUrlSmall: nil,
        sourceUrl: "https://example.com",
        uuid: "123",
        youtubeUrl: "https://youtube.com",
        description: "A classic Italian pasta dish."
    ))
}
