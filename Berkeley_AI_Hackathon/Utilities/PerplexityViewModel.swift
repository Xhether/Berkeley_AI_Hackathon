//
//  PerplexityViewModel.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 9/3/24.
//

import SwiftUI

class PerplexityViewModel: ObservableObject {
    private let apiClient: PerplexityAPIClient
    @Published var response: String = ""
    @Published var isLoading = false
    
    
    init(apiKey: String) {
        self.apiClient = PerplexityAPIClient(apiKey: apiKey)
    }
    
    func sendQuery(_ query: String) {
        isLoading = true
        Task {
            do {
                let result = try await apiClient.query(query)
                DispatchQueue.main.async {
                    self.response = result
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.response = "Error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
