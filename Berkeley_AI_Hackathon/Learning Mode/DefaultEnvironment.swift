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
            VStack{
                HStack{
                    Button(action: {
                        self.showMenu.toggle()
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 30))
                            .padding(.leading,20)
                            .foregroundColor(.black)
                    })
                    Spacer()
                    
                    Circle()
                        .frame(width:30,height: 30)
                        .padding(.trailing)
                    
                }
                
                if showMenu == true{
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 200,height: 64)
                            .padding(.trailing,120)
                            .foregroundColor(.gray)
                        
                        VStack{
                            NavigationLink{
                                Settings()
                            } label: {
                                Text("Settings")
                                    .foregroundStyle(.black)
                            }
                            Divider()
                                .frame(width: 200)
                            NavigationLink{
                                GrowthSpace()
                            } label: {
                                Text("Growth Space")
                                    .foregroundStyle(.black)
                                
                            }
                        }.padding(.trailing,116)
                    
                        }
                    
                }
                
                
                
                
                Spacer()
                if started != true{
                    ZStack{
                        RoundedRectangle(cornerRadius: 10.0)
                            .frame(width: 360,height: 100)
                            .foregroundColor(.gray)
                        
                        Text(defaultPrompts[currentIndex])
                            .font(.title)
                            .frame(width: 360, height: 100)
                            .transition(.opacity)
                            .onReceive(timer) { _ in
                                // Update the current index, wrapping around to the start if necessary
                                currentIndex = (currentIndex + 1) % defaultPrompts.count
                            }
                    }
                    ZStack{
                        Circle()
                            .frame(width: 80,height: 80)
                        Image(systemName: "mic")
                            .foregroundColor(Color.white)
                            .font(.system(size: 52))
                    }
                }
                
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray)
                        .frame(width: 360, height: 36)
                    
                    TextField(
                        "Feel like Typing?",
                        text: $userPrompt
                    )
                    .padding(.leading, 30 )
                }
                //grab final userprompt each time and query a response from ai...
                //once we grab some speech or a prompt is typed, change started to true...
                
            }
        }
    }
}

#Preview {
    DefaultEnvironment()
}
