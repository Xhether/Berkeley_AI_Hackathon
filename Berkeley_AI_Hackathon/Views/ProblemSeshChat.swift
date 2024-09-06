//
//  ProblemSeshChat.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

struct ProblemSeshChat: View {
    @State var isStarted = false
    @State var answer = ""
    @State var sent = false
    var body: some View {
        NavigationStack{
            Text("Problem Session")
            Text("Hi [NAME], I'm going to give you 3 problems based off of your courses and learning topics, let me know when you're ready to start!")
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(.blue))
                .frame(width: 300)
            
            if isStarted == true {
                
                HStack{
                    TextField("Share Your Answer!", text: $answer)
                    
                    Toggle("Send", isOn: $sent)
                        .toggleStyle(.button)
                }
                    
            }
            Spacer()
            VStack{
                
                Toggle("Become an academic weapon!📗",isOn: $isStarted)
                    .padding()
                    .toggleStyle(.button)
                
                if isStarted == false {
                    NavigationLink("Go back 😔"){
                        GrowthSpace(configs: Configurations(id: UUID(), favSubject: "Computer Science", courses: ["Coursera"], topics: [""], level: "Medium"))
                    }
                }
                
            }
            
            
        }
    }
}

#Preview {
    ProblemSeshChat()
}
