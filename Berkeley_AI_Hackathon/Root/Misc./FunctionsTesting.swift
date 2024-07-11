//
//  FunctionsTesting.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 7/10/24.
//

import SwiftUI

struct FunctionsTesting: View {
    @State var backgroundColor: Color = Color.pink
    
    var body: some View {
        
       
        ZStack{
            //background
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            //content
            contentLayer
        }
    }
    
    var contentLayer: some View {
        VStack{
            Text("Title")
                .font(.largeTitle)
            Button {
                buttonPressed()
            } label: {
                Text("Press Me")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            }
        }
    }
    
    func buttonPressed(){
        backgroundColor = .yellow

    }
}

#Preview {
    FunctionsTesting()
}
