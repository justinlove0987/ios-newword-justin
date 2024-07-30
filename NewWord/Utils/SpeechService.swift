//
//  SpeechService.swift
//  NewWord
//
//  Created by justin on 2024/7/30.
//

import UIKit
import AVFoundation

enum VoiceType: String {
    case undefined
    case waveNetMale = "en-US-Wavenet-D"
    case enUSStandardCFemale = "en-US-Standard-C"
    case enUSStandardFFemale = "en-US-Standard-F"
    case standardFemale = "en-US-Standard-E"
    case standardMale = "en-US-Standard-D"
    case enUSJourneyOFemale = "en-US-Journey-O"
    case enUSJourneyFFemale = "en-US-Journey-F"
    case enUSJourneyDMale = "en-US-Journey-D"
}

let ttsAPIUrl = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"
let APIKey = "AIzaSyAu4IIgc3WDKFuq8AGD6g1Rliz83qS5q0k"

class SpeechService: NSObject, AVAudioPlayerDelegate {
    
    private let downloadQueue = DispatchQueue(label: "com.yourapp.speechservice.downloadQueue", attributes: .concurrent)
    
    static let shared = SpeechService()
    private(set) var busy: Bool = false
    
    private var player: AVAudioPlayer?
    
    var finishCallback: (() -> Void)?
    var stopCallback: (() -> ())?
    var startCallback: (() ->())?
    
    func speak(_ audioData: Data?) {
        guard !self.busy else {
            print("Speech Service busy!")
            return
        }
        
        guard let audioData else {
            return
        }
        
        DispatchQueue.main.async {
            self.player = try! AVAudioPlayer(data: audioData)
            self.player?.delegate = self
            self.player!.play()
            
            self.startCallback?()
        }
    }
    
    func stop() {
        if let player = self.player, player.isPlaying {
            player.stop()
            self.busy = false
            self.player = nil
            
            stopCallback?()
        }
    }
    
    func download(text: String, voiceType: VoiceType = .waveNetMale, completion: @escaping (Data?) -> Void) {
        downloadQueue.async {
            let postData = self.buildPostData(text: text, voiceType: voiceType)
            let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePOSTRequest(url: ttsAPIUrl, postData: postData, headers: headers)
            
            // 獲取 `audioContent` 並解碼
            guard let audioContent = response["audioContent"] as? String,
                  let audioData = Data(base64Encoded: audioContent) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(audioData)
            }
        }
    }
    
    private func buildPostData(text: String, voiceType: VoiceType) -> Data {
        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": "en-US"
        ]
        
        if voiceType != .undefined {
            voiceParams["name"] = voiceType.rawValue
        }
        
        let params: [String: Any] = [
            "input": [
                "ssml": text
            ],
            
            "voice": voiceParams,
            
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16"
            ],
            
            "enableTimePointing": ["SSML_MARK"]
        ]
        
        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    // Just a function that makes a POST request.
    private func makePOSTRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dict
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
        self.busy = false
        
        self.finishCallback?()
        self.finishCallback = nil
    }
    
    func getDuration(_ audioData: Data?) -> TimeInterval? {
        guard let audioData else { return nil }
        
        if let player = try? AVAudioPlayer(data: audioData) {
            let duration = player.duration // 音訊長度（秒）
            return duration
        }
        
        return nil
    }
    
    func fetchAndSpeak(text: String, voiceType: VoiceType = .waveNetMale, completion: @escaping (Data?) -> Void) {
        guard !self.busy else {
            print("Speech Service busy!")
            return
        }
        
        self.busy = true
        
        DispatchQueue.global(qos: .background).async {
            let postData = self.buildPostData(text: text, voiceType: voiceType)
            let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePOSTRequest(url: ttsAPIUrl, postData: postData, headers: headers)
            
            // Get the `audioContent` (as a base64 encoded string) from the response.
            guard let audioContent = response["audioContent"] as? String else {
                print("Invalid response: \(response)")
                self.busy = false
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Decode the base64 string into a Data object
            guard let audioData = Data(base64Encoded: audioContent) else {
                self.busy = false
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(audioData)
                self.busy = false
            }
        }
    }
}

