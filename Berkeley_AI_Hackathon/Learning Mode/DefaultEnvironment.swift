//
//  DefaultEnvironment.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

struct DefaultEnvironment: View {
    @State private var defaultPrompts = ["Ask Me About Newton's Second Law!", "Ask Me About Mathematical Induction!", "Ask Me About Graph Theory!"]
    @State private var started = false
    @State private var showMenu = false
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State private var userPrompt = ""
    var body: some View {
        NavigationStack{
            ZStack{
                Rectangle()
                    .foregroundStyle(
                        LinearGradient(colors: [Color.white,Color("blueG"),Color.white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 400,height: 900)

                VStack{
                    
                    Settings()
                        .padding(.top,64)
                    Spacer()
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 48, height: 148)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 48, height: 100)
                            .padding(.top,48)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 48, height: 100)
                            .padding(.top,48)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 48, height: 148)
                        
                    }.padding(.bottom,36)
                    
                    if started != true{
                        ZStack{
                            RoundedRectangle(cornerRadius: 10.0)
                                .frame(width: 360,height: 100)
                                .foregroundColor(.white)
                                .overlay( /// apply a rounded border
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 2)
                                )
                            
                            Text(defaultPrompts[currentIndex])
                                .font(.title)
                                .frame(width: 320, height: 100)
                                .transition(.opacity)
                                .onReceive(timer) { _ in
                                    // Update the current index, wrapping around to the start if necessary
                                    currentIndex = (currentIndex + 1) % defaultPrompts.count
                                }
                        }
                        ZStack{
                            Circle()
                                .frame(width: 64,height: 64)
                            Image(systemName: "mic")
                                .foregroundColor(Color.white)
                                .font(.system(size: 44))
                        }.padding(.top)
                    }
                    Text("Press to Speak")
                        .foregroundStyle(.gray)
                    
                    //send voice,
                    
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    DefaultEnvironment()
}
