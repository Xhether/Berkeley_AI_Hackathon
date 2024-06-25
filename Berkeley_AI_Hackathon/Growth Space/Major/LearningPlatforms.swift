//
//  LearningPlatforms.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

struct LearningPlatforms: View {
    let pickedPlatform: String
    
    
    
    var body: some View{
        VStack{
            if pickedPlatform == "Coursera"{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 340,height: 32)
                        
                    
                    Text("What is Coursera")
                    
                }
                //get response to what is coursera
                
            } else if pickedPlatform == "Brilliant"{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 340,height: 32)
                    Image(systemName: "Brilliant")
                    Text("What is Brilliant")
                }
            } else if pickedPlatform == "MIT CourseWare"{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 340,height: 32)
                    Text("What is MIT CourseWare")
                }
            } else if pickedPlatform == "Codeacademy" {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 340,height: 32)
                    Text("What is Codeacademy")
                }
            } else if pickedPlatform == "W3Schools" {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 340,height: 32)
                    Text("What is W3Schools")
                }
            } else if pickedPlatform == "Code.org"{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 340,height: 32)
                    Text("What is Code.org")
                }
            } else if pickedPlatform == "Khan Academy" {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 340,height: 32)
                    Text("What is Khan Academy")
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LearningPlatforms(pickedPlatform: "Coursera")
}
