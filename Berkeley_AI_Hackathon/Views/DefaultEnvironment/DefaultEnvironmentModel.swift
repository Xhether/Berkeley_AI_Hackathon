//
//  DefaultEnvironmentModel.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 7/10/24.
//

//import Foundation
//
//class DefaultEnvironmentModel: ObservableObject {
//    @Published var isRecording = false
//    @Published var transcription = ""
//    
//    private let audioRecorder = AudioRecorder()
//    
//    init() {
//        audioRecorder.transcriptionCallback = { [weak self] transcribedText in
//            self?.transcription = transcribedText
//        }
//    }
//    
//    func startRecording() {
//        audioRecorder.startRecording()
//        isRecording = true
//    }
//    
//    func stopRecording() {
//        audioRecorder.stopRecording()
//        isRecording = false
//    }
//}
