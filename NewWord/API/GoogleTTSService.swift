//
//  SpeechService.swift
//  NewWord
//
//  Created by justin on 2024/7/30.
//

import UIKit
import AVFoundation
import NaturalLanguage

enum VoiceType: String {
    case undefined
    case enUSWavenetDMale = "en-US-Wavenet-D"
    case enUSStandardE = "en-US-Standard-E"
    case enUSStandardDMale = "en-US-Standard-D"
    case enUSStandardCFemale = "en-US-Standard-C"
    case enUSStandardFFemale = "en-US-Standard-F"
    case enUSJourneyOFemale = "en-US-Journey-O"
    case enUSJourneyFFemale = "en-US-Journey-F"
    case enUSJourneyDMale = "en-US-Journey-D"
    case enUSNeural2JMale = "en-US-Neural2-J"
    case enUSNewsNMale = "en-US-News-N"
    case enUSWavenetFFemale = "en-US-Wavenet-F"
    case enUSWavenetHFemale = "en-US-Wavenet-H"
    case enUSCasualKMale = "en-US-Casual-K"
    case enUSStudioOFemale = "en-US-Studio-O"
    case enUSStudioQMale = "en-US-Studio-Q"
    case enUSPolyglot1Male = "en-US-Polyglot-1"
}

class GoogleTTSService: NSObject {

    enum SynthesisInput: String {
        case text
        case ssml
    }

    enum TimepointType: String {
        case SSML_MARK
        case TIMEPOINT_TYPE_UNSPECIFIED
    }

    private let downloadQueue = DispatchQueue(label: "com.yourapp.speechservice.downloadQueue", attributes: .concurrent)
    
    static let shared = GoogleTTSService()
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
    
    func download(text: String,
                  synthiesisInput: SynthesisInput = .text,
                  timepointType: TimepointType = .TIMEPOINT_TYPE_UNSPECIFIED,
                  voiceType: VoiceType = .enUSJourneyDMale,
                  completion: @escaping (Data?) -> Void) {

        downloadQueue.async {
            let postData = self.buildPostData(text: text,
                                              synthiesisInput: synthiesisInput,
                                              timepointType: timepointType,
                                              voiceType: voiceType)

            let headers = ["X-Goog-Api-Key": K.API.key, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePOSTRequest(url: K.API.tts, postData: postData, headers: headers)

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
    
    private func buildPostData(text: String,
                               synthiesisInput: SynthesisInput = .text,
                               timepointType: TimepointType = .TIMEPOINT_TYPE_UNSPECIFIED,
                               voiceType: VoiceType,
                               rate: Double = 1.0) -> Data {

        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": "en-US"
        ]
        
        if voiceType != .undefined {
            voiceParams["name"] = voiceType.rawValue
        }
        
        let params: [String: Any] = [
            "input": [
                synthiesisInput.rawValue: text
            ],
            
            "voice": voiceParams,
            
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16",
                "effectsProfileId": [
                    "small-bluetooth-speaker-class-device"
                  ],
                "pitch": 0,
                "speakingRate": rate
            ],
            
            "enableTimePointing": [timepointType.rawValue]
        ]

        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }

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
    
    func getDuration(_ audioData: Data?) -> TimeInterval? {
        guard let audioData else { return nil }
        
        if let player = try? AVAudioPlayer(data: audioData) {
            let duration = player.duration // 音訊長度（秒）
            return duration
        }
        
        return nil
    }
    
    func playAudioWithMarks(_ article: FSArticle) {
        guard let result = article.ttsSynthesisResult else { return }
        guard let audioData = result.audioData else { return }
        
        let text = article.content
        
        do {
            self.player = try AVAudioPlayer(data: audioData)
            self.player?.play()
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self, let player = self.player else {
                    timer.invalidate()
                    return
                }
                
                let currentTimeInSeconds = roundToOneDecimalPlace(player.currentTime)
                
                for timepoint in result.timepoints {
                    
                    // let markName = timepoint.markName
                    let markTime = roundToOneDecimalPlace(timepoint.timeSeconds)
                    
                    if markTime == currentTimeInSeconds && !currentTimeInSeconds.isZero  {
                        if let nsRange = timepoint.range, let range = Range(nsRange, in: text) {
                            let substring = text[range]
                            print("Selected text: \(substring) \(nsRange) \(currentTimeInSeconds)")
                        } else {
                            print("Invalid range")
                        }
                    }
                }
                
                // 如果音頻播放結束則停止計時器
                if !player.isPlaying {
                    timer.invalidate()
                }
            }
            
            
        } catch {
            
        }
    }

    func downloadSSML(_ text: String,
                      voiceType: VoiceType = .enUSPolyglot1Male,
                      rate: Double = 0.8,
                      completion: @escaping (CDPracticeAudio?, [CDTimepointInformation]?) -> Void) {

        var text = addMarksToText(text)
        text = wrapWithSpeakTags(text)
        
        downloadQueue.async {
            let postData = self.buildPostData(text: text,
                                              synthiesisInput: .ssml,
                                              timepointType: .SSML_MARK,
                                              voiceType: voiceType,
                                              rate: rate)
            
            let headers = ["X-Goog-Api-Key": K.API.key, 
                           "Content-Type": "application/json; charset=utf-8"]
            
            let response = self.makePOSTRequest(url: K.API.tts, postData: postData, headers: headers)
            
            // 獲取 `audioContent` 並解碼
            guard let audioContent = response["audioContent"] as? String,
                  let audioData = Data(base64Encoded: audioContent) else {
                DispatchQueue.main.async {
                    completion(nil,nil)
                }
                return
            }
            
            // 解析 timepoints 並封裝到 TimepointInfo 中
            var timepoints: [CDTimepointInformation] = []

            if let tpArray = response["timepoints"] as? [[String: Any]] {
                for tp in tpArray {
                    if let markName = tp["markName"] as? String,
                       let timeSeconds = tp["timeSeconds"] as? Double {
                        // 解析 markName 並生成 NSRange
                        let components = markName.split(separator: "_")
                        let range: NSRange? = {
                            if components.count == 3,
                               let location = Int(components[1]),
                               let length = Int(components[2]) {
                                return NSRange(location: location, length: length)
                            }
                            return nil
                        }()

                        
                        let timepointInformation = CoreDataManager.shared.createTimePointInformation(rangeLength: range?.length,
                                                                          rangeLocation: range?.location,
                                                                          timeSeconds: timeSeconds,
                                                                          markName: markName)

                        timepoints.append(timepointInformation)
                    }
                }
            }
            
            let audioResrouce = CoreDataManager.shared.createPracticeAudio()
            audioResrouce.data = audioData

            DispatchQueue.main.async {
                completion(audioResrouce,timepoints)
            }
        }
    }
    
    func addMarksToText(_ text: String) -> String {
        let tokenizer = NLTokenizer(unit: .word)
        
        var markedText = ""
        var currentPosition = 0
        var previousWordRange: Range<String.Index>? = nil
        
        tokenizer.string = text
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { (range, _) in
            let word = text[range]
            let wordLength = word.count
            
            if let previousWordRange {
                let lowerBound = previousWordRange.upperBound
                let upperBound = range.lowerBound
                
                if let range = rangeFromIndices(in: text, from: lowerBound, to: upperBound) {
                    let substring = text[range]
                    
                    markedText += String(substring)
                    currentPosition += substring.count
                }
            }
            
            let wordMark = "<mark name=\"w_\(currentPosition)_\(wordLength)\"/>"
            markedText += "\(wordMark) \(word)"
            previousWordRange = range
            
            currentPosition += wordLength
            
            return true
        }
        
        return markedText
    }
    
    func wrapWithSpeakTags(_ text: String) -> String {
        return "<speak>\(text)</speak>"
    }
    
    func rangeFromIndices(in text: String, from startIndex: String.Index, to endIndex: String.Index) -> Range<String.Index>? {
        // 確保起始和結束索引是有效的
        guard startIndex <= endIndex else {
            return nil
        }
        // 返回字符串中的範圍
        return startIndex..<endIndex
    }
    
    func roundToOneDecimalPlace(_ value: Double) -> Double {
        return round(value * 10) / 10
    }
}

extension GoogleTTSService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
        self.busy = false

        self.finishCallback?()
        self.finishCallback = nil
    }
}

struct TTSSynthesisResult: Hashable {
    let audioId: String
    var timepoints: [FSTimepointInfo]
    
    var audioData: Data?
}

struct FSTimepointInfo: Hashable {
    var range: NSRange?
    let markName: String
    let timeSeconds: Double
}
