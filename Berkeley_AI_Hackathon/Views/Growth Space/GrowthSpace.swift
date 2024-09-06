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
    @StateObject private var dataStore = DataStore.shared
    let learningPlatforms = ["Coursera","Codeacademy","Brilliant", "MIT CourseWare", "Code.org", "Khan Academy", "W3Schools"]
    let communities = ["Kaggle", "Girls Who Code", "Colorstack", "Reddit"]
    let courses = ["Data Structures and Functional Programming", "Engineering Probability and Statistics"]
    
    var body: some View {
        ScrollView(.vertical){
            NavigationStack{
                VStack{
                    Settings()
                        .padding(.leading,40)
                        .padding(.trailing,40)
                    
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
                                        //fix border uglahhh
                                            .overlay( /// apply a rounded border
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black, lineWidth: 3)
                                                    
                                                
                                            )
                                        Text(platform)
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                        }
                        .padding(.leading,60)
                        .padding(.trailing,60)
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
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                        }
                        .padding(.leading,60)
                        .padding(.trailing,60)
                    }
                    VStack{
                        Text("Problem Session")
                            .foregroundStyle(.gray)
                        Text("Configurations")
                            .font(.title)
                            .padding(.leading,44)
                            .frame(width: 300)
                    }
                    .padding(.trailing, 172)
                    .padding(.top,28)
                    
                    VStack(alignment: .leading){
                        Text("Courses:")
                        //for each course...
                        ForEach(dataStore.items) { item in
                            Text(item)
                        }
                        
                        Text("Topics:")
                        //for each topic...
                        Text("Levels:")
                        Text("Medium (Recommended)")

                    }
                    
                    NavigationLink {
                        PerplexityView(apiKey: "")
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 336, height: 58)
                                .foregroundColor(.gray)
                            Text("Begin Problem Session")
                                .foregroundStyle(.black)
                        }
                    }
                    Spacer()
                }
            }.navigationBarBackButtonHidden(true)
        }
    }
}


#Preview {
    GrowthSpace(configs: Configurations(id: UUID(), favSubject: "Computer Science", courses: [], topics: [], level: "Medium"))
}
