//
//  PerplexityAPI.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 9/3/24.
//

import Foundation

class PerplexityAPIClient {
    private let apiKey: String
    private let baseURL = "https://api.perplexity.ai"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func query(_ prompt: String) async throws -> String {
        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "mistral-7b-instruct",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(PerplexityResponse.self, from: data)
        return response.choices.first?.message.content ?? "No response"
    }
}

struct PerplexityResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}
