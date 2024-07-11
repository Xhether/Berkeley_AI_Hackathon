//
//  Configurations.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

struct Configurations: Codable, Identifiable {
    let id: UUID
    let favSubject: String
    let courses: [String]
    let topics: [String]
    let level: String
}
