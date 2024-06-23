//
//  GrowthSpace.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI


extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

struct GrowthSpace: View {
    let configs: Configurations
    let learningPlatforms = ["Coursera","Codeacademy","Brilliant", "MIT CourseWare", "Code.org", "Khan Academy", "W3Schools"]
    let communities = ["Kaggle", "Girls Who Code", "Colorstack", "Reddit"]
    
    var body: some View {
        
        NavigationStack{
            VStack{
                Settings()
                
                
                VStack{
                    Text("Field of Study or Favorite Subject")
                        .foregroundStyle(.gray)
                    Text(configs.favSubject)
                        .padding(.trailing,32)
                        .font(.title)
                }
                .padding(.trailing,52)
                .padding(.top,40)
                
                Text("Top Learning Platforms")
                    .padding(.top)
                ScrollView(.horizontal){
                    HStack{
                        ForEach(learningPlatforms) { platform in
                            NavigationLink {
                                LearningPlatforms(pickedPlatform: platform)
                            } label: {
                                VStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 160,height: 80)
                                        .overlay( /// apply a rounded border
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black, lineWidth: 2)
                                                
                                        )
                                    Text(platform)
                                }
                            }
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    
                }
                Text("Most Prominent Communities")
                    .padding(.top)
                ScrollView(.horizontal){
                    HStack{
                        ForEach(communities) { community in
                            NavigationLink {
                                LearningPlatforms(pickedPlatform: community)
                            } label: {
                                VStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 160,height: 80)
                                        .overlay( /// apply a rounded border
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black, lineWidth: 2)
                                                
                                        )
                                    Text(community)
                                }
                            }
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    Spacer()
                    
                }
            }
        }
    }
}

#Preview {
    GrowthSpace(configs: Configurations(id: UUID(), favSubject: "Computer Science", courses: [""], topics: [""], level: "Medium"))
}
