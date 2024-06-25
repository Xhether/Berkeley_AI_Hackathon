//
//  DefaultEnvironment.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI
import Alamofire
import AVFAudio

struct DefaultEnvironment: View {
    @State private var defaultPrompts = ["Ask Me About Newton's Second Law!", "Ask Me About Mathematical Induction!", "Ask Me About Graph Theory!"]
    @State private var started = false
    @State private var showMenu = false
    @State var canRecord = false
    @State var responseMessage: String = "No response yet"
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State private var userPrompt = ""
    @StateObject private var networkManager = NetworkManager()
    
    
    var body: some View {
        NavigationStack{
           /* ZStack{
                Rectangle()
                    .foregroundStyle(
                        LinearGradient(colors: [Color.white,Color("blueG"),Color.white], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 400,height: 900)
                */
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
                        
                        if canRecord == false{
                            Button{
                                requestMicrophoneAccess { granted in
                                    canRecord = granted
                                }
                            } label: {
                                ZStack{
                                    Circle()
                                        .frame(width: 64,height: 64)
                                    Image(systemName: "mic")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 44))
                                }
                            }.padding(.top)
                        } else {
                            Button{
                                //if we don't hear audio above ..., we fire the message
                                networkManager.startChat()
                            } label: {
                                ZStack{
                                    Circle()
                                        .frame(width: 64,height: 64)
                                        .foregroundColor(.red)
                                    Image(systemName: "mic")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 44))
                                }
                            }.padding(.top)
                        }
                       
                    
                    
                }

                    Text("Press to Speak")
                        .foregroundStyle(.gray)
                    
                    //send voice,
                    
                    
                    Spacer()
                }
            }.navigationBarBackButtonHidden(true)
        }
    }

    
  
 /*
func startChat() {
    let url = "http://localhost:8000/api/start_chat"
    AF.request(url, method: .post, encoding: JSONEncoding.default)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Response JSON: \(value)")
                //self.responseMessage = "Success: \(value)"
            case .failure(let error):
                print("Error: \(error)")
                //self.responseMessage = "Error: \(error.localizedDescription)"
            }
        }
}*/

        
    
    func requestMicrophoneAccess(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }


    func endChat() {
        let url = "http://localhost:8000/api/end_chat"
        AF.request(url, method: .post, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
               case .success(let value):
                    print("Response JSON: \(value)")
                    //self.responseMessage = "Success: \(value)"
                case .failure(let error):
                    print("Error: \(error)")
                    //self.responseMessage = "Error: \(error.localizedDescription)"
                }
           }
    }


#Preview {
    DefaultEnvironment()
}
