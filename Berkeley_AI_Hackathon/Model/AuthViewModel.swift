//
//  AuthViewModel.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import Foundation
import Alamofire
import SwiftUI


    class NetworkManager: ObservableObject {
        @Published var responseMessage: String = ""
        @Published var chatHistory: [String] = []
        
        func startChat() {
            guard let url = URL(string: "http://localhost:8000/api/start_chat") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                        DispatchQueue.main.async {
                            self.responseMessage = "Chat started"
                        }
                    }
                }
            }
            
            task.resume()
        }
        
        func stopChat() {
            guard let url = URL(string: "http://localhost:8000/api/stop_chat") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                        DispatchQueue.main.async {
                            self.chatHistory = decodedResponse.data
                            self.responseMessage = "Chat stopped"
                        }
                    }
                }
            }
            
            task.resume()
        }
        
        func fetchChatHistory() {
            guard let url = URL(string: "http://localhost:8000/api/chat_history") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                        DispatchQueue.main.async {
                            self.chatHistory = decodedResponse.data
                        }
                    }
                }
            }
            
            task.resume()
        }
    }

    struct ApiResponse: Codable {
        let success: Bool
        let data: [String]
    }


