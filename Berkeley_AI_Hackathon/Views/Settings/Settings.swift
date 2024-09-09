//
//  Settings.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

struct Settings: View{
    @State private var showMenu = false
    var body: some View{
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
               
            }
        }
        if showMenu == true{
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black,lineWidth:2)
                    .frame(width: 200,height: 100)
                    .padding(.trailing,120)
                    .foregroundColor(.white)
                VStack{
                    NavigationLink{
                        ConfigurationsView()
                    } label: {
                        Text("Settings")
                            .foregroundStyle(.black)
                    }
                    Divider()
                        .frame(width: 200)
                    NavigationLink{
                        GrowthSpace(configs: Configurations(id: UUID(), favSubject: "Computer Science", courses: [], topics: [], level: "Medium"))
                    } label: {
                        Text("Growth Space")
                            .foregroundStyle(.black)
                    }
                    Divider()
                        .frame(width: 200)
                    NavigationLink{
                        Home()
                    } label: {
                        Text("Home")
                            .foregroundStyle(.black)
                    }
                }.padding(.trailing,116)
                    .navigationBarBackButtonHidden(true)
            }
          }
       }
    }
    
    #Preview {
        Settings()
    }
