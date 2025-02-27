//
//  ContentView.swift
//  FetchRecipes
//
//  Created by Leslie Mora Ponce on 2/26/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedSegment = 0
    let segments = ["Normal", "Malformed", "Empty"]

    @State var recipes:[Recipe] = []
    @State private var showAlert = false
    @State private var errorString = ""

    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Options", selection: $selectedSegment) {
                                ForEach(0..<segments.count, id: \.self) { index in
                                    Text(segments[index])
                                }
                            }
                .pickerStyle(.segmented)
                .onChange(of: selectedSegment) { _, _ in
                    self.recipes = []
                    Task {
                        await fetchRecipes()
                    }
                }
                .padding(8)
                
                List {
                    ForEach(recipes, id: \.uuid) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeCellView(recipe: recipe)

                        }
                    }
                }.listStyle(.plain)

                Spacer()
            }
            .navigationTitle("Recipes")
            
        }.onAppear {
            Task {
                await fetchRecipes()
            }
        }
        .alert("Error", isPresented: $showAlert){
            Button("OK", role: .cancel) {
                showAlert = false
                }
            }message: {
                Text(errorString)
        }
    }
    

    func getSelectedURL() -> String {
        switch selectedSegment {
        case 0:
            return "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        case 1:
            return "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json"
        case 2:
            return "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json"
        default:
            return "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
        }
    }
    
    func fetchRecipes() async {
        let urlString = getSelectedURL()
        print("Fetching from: \(urlString)")
        
        do {
            recipes = try await NetworkManager.shared.fetchRecipes(from: urlString)
        } catch {
            
            switch error {
            case is DecodingError: errorString = "Malformed Data: \(error.localizedDescription)"
            default: errorString = "Failed to fetch recipes: \(error.localizedDescription)"
            }
            showAlert = true
        }
        
    }

}
 
#Preview {
    ContentView()
}
