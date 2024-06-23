//
//  Home.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

struct Home: View {
    var body: some View {
    
            NavigationStack{
                
                
                VStack {
                    Spacer()
                    Text("Ambrose AI")
                        .fontWeight(.bold)
                    //rectangular button to go to default chat screen
                    Spacer()
                    NavigationLink {
                        DefaultEnvironment()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerSize: CGSize(width:10, height: 10))
                                .frame(width: 264,height: 36)
                                .foregroundColor(.black)
                            
                            Text("Tap to Continue")
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }

    

#Preview {
    Home()
}


