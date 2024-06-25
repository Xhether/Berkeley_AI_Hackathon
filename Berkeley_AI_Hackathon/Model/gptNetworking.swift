//
//  gptNetworking.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/23/24.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private init() {}
    
    private let baseURL = "http://localhost:8000/api"
    
    func startChat(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/start_chat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "Invalid data", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(responseString))
        }
        
        task.resume()
    }
    
    func stopChat(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/stop_chat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = try? JSONDecoder().decode(ChatResponse.self, from: data) else {
                completion(.failure(NSError(domain: "Invalid data", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(response.data))
        }
        
        task.resume()
    }
    
    func sendMessage(_ message: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/send_chat") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = try? JSONDecoder().decode(ChatResponse.self, from: data) else {
                completion(.failure(NSError(domain: "Invalid data", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(response.data))
        }
        
        task.resume()
    }
    
    func fetchEducationalResources(topic: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/fetch_educational_resources") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["topic": topic]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = try? JSONDecoder().decode(ResourcesResponse.self, from: data) else {
                completion(.failure(NSError(domain: "Invalid data", code: 0, userInfo: nil)))
                return
            }
            
            completion(.success(response.data))
        }
        
        task.resume()
    }
}

struct ChatResponse: Decodable {
    let data: [String]
}

struct ResourcesResponse: Decodable {
    let data: [String]
}
