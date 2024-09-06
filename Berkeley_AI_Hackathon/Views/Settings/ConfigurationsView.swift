//
//  ConfigurationsView.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI

//pfp + settings
struct ConfigurationsView: View {
    @EnvironmentObject var configViewModel: ConfigurationsViewModel
    @StateObject private var dataStore = DataStore.shared
    @State private var course = ""
    @State private var topic = ""

    var body: some View {
        Spacer()
        
     Text("Please indicate the courses you'd like to grow in")
            .padding()
            .multilineTextAlignment(.center)
            .background(RoundedRectangle(cornerRadius: 20).foregroundColor(.brown))
    
        
        List(dataStore.items, id: \.self) { course in
            HStack(alignment: .center, content: {
                Text(course)
                    .padding(.trailing)
                    
                Button("", systemImage: "x.circle", action: {dataStore.removeItem(course)})
            })
        }
        .scrollContentBackground(.hidden)
        .background(Color.white)

        TextField("Enter a Course", text: $course)
            .multilineTextAlignment(.center)
        
        Button(action: {dataStore.appendItem(course)}) {
            Text("Press Me")
        }
        
//   Button("Publish", action: configViewModel.postCourse(course: course))
     Text("Please indicate the content you're struggling with")
            .padding()
            .multilineTextAlignment(.center)
            .background(RoundedRectangle(cornerRadius: 20).foregroundColor(.brown))

        TextField("Enter a Course", text: $topic)
            .multilineTextAlignment(.center)
            .padding(.top)
        
        Button(action: {configViewModel.postCourse(course: course)}) {
            Text("Press Me")
        }
        
    List(configViewModel.courses, id: \.self) { course in
                 Text(course)
            }
    }
}

#Preview {
    ConfigurationsView()
        .environmentObject(ConfigurationsViewModel())
}
