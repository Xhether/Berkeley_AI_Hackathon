//
//  ConfigurationsViewModel.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 9/4/24.
//

import SwiftUI

class ConfigurationsViewModel: ObservableObject{
    @Published var courses : [String] = []
    @Published var topics : [String] = []
    
    
    func postCourse(course: String) -> Void{
        courses.append(course)
    }
    
    func postTopic(topic: String) -> Void{
        topics.append(topic)
    }
    
}
