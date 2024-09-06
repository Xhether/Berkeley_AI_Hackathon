//
//  ElevenLabsHandling.swift
//  Berkeley_AI_Hackathon
//
//  Created by Charles Liggins on 9/4/24.
//

//import Foundation
//import AVFoundation
//
//func textToSpeech(text: String, voiceId: String, apiKey: String, completion: @escaping (URL?) -> Void) {
//    let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)/stream")!
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
//    
//    let parameters: [String: Any] = [
//        "text": text,
//        "model_id": "eleven_multilingual_v2",
//        "voice_settings": [
//            "stability": 0.5,
//            "similarity_boost": 0.8
//        ]
//    ]
//    
//    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//    
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        guard let data = data, error == nil else {
//            print("Error: \(error?.localizedDescription ?? "Unknown error")")
//            completion(nil)
//            return
//        }
//        
//        // Save the audio data to a file
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let audioURL = tempDirectory.appendingPathComponent("output.mp3")
//        
//        //saving the audio
//        do {
//            try data.write(to: audioURL)
//            completion(audioURL)
//        } catch {
//            print("Failed to save audio: \(error.localizedDescription)")
//            completion(nil)
//        }
//    }
//    
//    task.resume()
//}
//
//func playAudio(from url: URL) {
//    let player = AVPlayer(url: url)
//    player.play()
//}
//
//// Usage
//
