//
//  DataStore.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 9/4/24.
//

import SwiftUI

class DataStore: ObservableObject {
    static let shared = DataStore() // Singleton instance
    
    @Published var items: [String] = []
    
    private init() {
        loadItems()
    }
    
    func appendItem(_ item: String) {
        items.append(item)
        saveItems()
    }
    
    private func saveItems() {
        // Save to UserDefaults for persistence
        UserDefaults.standard.set(items, forKey: "storedItems")
    }
    
    func removeItem(_ item: String) {
         items.removeAll { $0 == item }
         saveItems()
    }
    
    private func loadItems() {
        // Load from UserDefaults
        if let savedItems = UserDefaults.standard.array(forKey: "storedItems") as? [String] {
            items = savedItems
        }
    }
}
