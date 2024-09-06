//
//  DefaultEnvironment.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 6/22/24.
//

import SwiftUI
import Alamofire
import AVFAudio
import AVFoundation




struct DefaultEnvironment: View {
    @State private var defaultPrompts = ["Ask Me About Newton's Second Law!", "Ask Me About Mathematical Induction!", "Ask Me About Graph Theory!"]
    @State private var started = false
    @State private var showMenu = false
    @State var responseMessage: String = "No response yet"
    
    @StateObject private var viewModel = DefaultEnvironmentModel()

    
    @State private var inputText: String = ""
    @State private var isPlaying: Bool = false
    @State private var audioPlayer: AVPlayer?
    
    // responses variable
    // sent variable
    
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State private var userPrompt = ""
    
    var body: some View {
        NavigationStack{
            VStack{
                Settings()
                Spacer()
                
                
                //content
                voiceBar
                
                VStack {
                           Button(action: {
                               if viewModel.isRecording {
                                   viewModel.stopRecording()
                               } else {
                                   viewModel.startRecording()
                               }
                           }) {
                               Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                           }
                           .padding()
                           
                    if !viewModel.transcription.isEmpty {
                               Text("Transcription:")
                                   .font(.headline)
                                   .padding(.top)
                               
                               ScrollView {
                                   Text(viewModel.transcription)
                                       .padding()
                               }
                           }
                   }
            
                //get voice to text data on one side, and put it into bubble
                
                //get text response from AI and put it on the other side
                TextField("Enter text to speak", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    generateAndPlaySpeech()
                }) {
                    Text(isPlaying ? "Stop" : "Speak")
                }
                .padding()
            }
            
            Spacer()
            
            //                    if started != true{
            //                        rotatingText
            //                        if canRecord == false{
            //                            Button{
            //                                requestMicrophoneAccess { granted in
            //                                    canRecord = granted
            //                                }
            //                            } label: {
            //                                ZStack{
            //                                    Circle()
            //                                        .frame(width: 64,height: 64)
            //                                    Circle()
            //                                        .frame(width: 44,height: 44)
            //                                        .foregroundColor(.black)
            //
            //                                }
            //                                .padding(.top)
            //                            }.padding(.top)
            //                        } else {
            //
            //                            Button{
            //                                //   if we don't hear audio above ..., we fire the message
            //                                //   networkManager.startChat()
            //                            } label: {
            //
            //                                micIcon
            //                            }.padding(.top)
            //                        }
            //                    }
            
            //                    Text("Press to Speak")
            //                        .foregroundStyle(.gray)
            //                    //send voice,
            //
            //                    Spacer()
            
            //                    textToSpeech(text: "Hello, world!", voiceId: "21m00Tcm4TlvDq8ikWAM", apiKey: "YOUR_API_KEY") { audioURL in
            //                        if let audioURL = audioURL {
            //                            playAudio(from: audioURL)
            //                        }
            //                    }
            
            
        }
    }/*.navigationBarBackButtonHidden(true)*/
    
    
    
    // functions
    func recording(recordingPermission: Bool){
        
    }
    
    //view variables
    var micIcon: some View{
        ZStack{
            Circle()
                .frame(width: 64,height: 64)
                .foregroundColor(.red)
            Image(systemName: "mic")
                .foregroundColor(Color.white)
                .font(.system(size: 44))
        }
    }
    
    //    var rotatingText: some View{
    //                Text(defaultPrompts[currentIndex])
    //                .font(.title)
    //                .frame(width: 320, height: 100)
    //                .transition(.opacity)
    //                .overlay( /// apply a rounded border
    //                    RoundedRectangle(cornerRadius: 10)
    //                        .stroke(.black, lineWidth: 2)
    //                    )
    //                .onReceive(timer) { _ in
    //                    // Update the current index, wrapping around to the start if necessary
    //                    currentIndex = (currentIndex + 1) % defaultPrompts.count
    //        }
    //    }
    
    var voiceBar: some View{
        HStack{
            largeBar
            smallBar
            smallBar
            largeBar
        }.padding(.bottom,36)
    }
    
    var smallBar: some View{
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 48, height: 100)
            .padding(.top,48)
    }
    
    var largeBar: some View{
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 48, height: 148)
    }
    
    
    
    func generateAndPlaySpeech() {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            textToSpeech(text: inputText, voiceId: "21m00Tcm4TlvDq8ikWAM", apiKey: "sk_05054e7631acf83995f47a4802f79c95a829186eff15d22c") { audioURL in
                DispatchQueue.main.async {
                    if let audioURL = audioURL {
                        self.audioPlayer = AVPlayer(url: audioURL)
                        self.audioPlayer?.play()
                        self.isPlaying = true
                    }
                }
            }
        }
    }
    
    
    func textToSpeech(text: String, voiceId: String, apiKey: String, completion: @escaping (URL?) -> Void) {
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)/stream")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let parameters: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": [
                "stability": 0.5,
                "similarity_boost": 0.8
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            // Save the audio data to a file
            let tempDirectory = FileManager.default.temporaryDirectory
            let audioURL = tempDirectory.appendingPathComponent("output.mp3")
            
            do {
                try data.write(to: audioURL)
                completion(audioURL)
            } catch {
                print("Failed to save audio: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}
#Preview {
    DefaultEnvironment()
}
