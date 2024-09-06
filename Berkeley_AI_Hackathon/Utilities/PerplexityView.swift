//
//  PerplexityView.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 9/3/24.
//

import SwiftUI

struct PerplexityView: View {
    @StateObject private var viewModel: PerplexityViewModel
    @State private var query: String = ""
    @State var isStarted = false
    init(apiKey: String) {
        _viewModel = StateObject(wrappedValue: PerplexityViewModel(apiKey: apiKey))
    }
    
    var body: some View {
        ScrollView{
            
            VStack {
                Text("Problem Session")
                Text("Hi [NAME], I'm going to give you 3 problems based off of your courses and learning topics, let me know when you're ready to start!")
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(.blue))
                    .frame(width: 300)
            }
            
            Spacer()
            
            
            if isStarted == true {
                //post initial response to given preferences
                
//                viewModel.sendQuery("Please Generate me 3 easy questions based on the following courses and learning goals:" + courses + topics )
                
                TextField("Enter your Response", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text(viewModel.response)
                        .padding()
                }
                
                Button("Send Query") {
                    viewModel.sendQuery(query)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20.0).foregroundColor(.gray))
                .disabled(viewModel.isLoading)
            }
            
            
            
            
            Toggle("Become an academic weapon!📗",isOn: $isStarted)
                .padding()
                .toggleStyle(.button)
          
            
         
            
        }
    
        }
    
}

#Preview {
    PerplexityView(apiKey: "")
}
