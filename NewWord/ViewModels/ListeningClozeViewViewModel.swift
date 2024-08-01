//
//  ListeningClozeViewViewModel.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/7/26.
//

import Foundation
import AVKit

struct ListeningClozeViewViewModel {
    var card: CDCard?
    
    let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()

    func getOriginalText() -> String? {
        guard let card else { return nil }
        
        return CoreDataManager.shared.getClozeWord(from: card)
    }
    
    func getTranslatedText() -> String? {
        guard let card else { return nil }
        
        return CoreDataManager.shared.getHint(from: card)
    }

    func speak(text: String, voiceName: String? = nil) {
        // 創建 AVSpeechUtterance 實例並設定要講的文字
        let utterance = AVSpeechUtterance(string: text)

        // 設定語音的語言（例如，英文）
        if let voiceName = voiceName {
            // 根據語音名稱選擇語音
            let availableVoices = AVSpeechSynthesisVoice.speechVoices()
            if let selectedVoice = availableVoices.first(where: { $0.name == voiceName && $0.language == "en-US" }) {
                utterance.voice = selectedVoice
            } else {
                print("指定的語音名稱 '\(voiceName)' 無法找到。")
                // 默認為未指定語音名稱時的行為
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        // 設定語速和音調（可根據需要調整）
        utterance.rate = 0.35
        utterance.pitchMultiplier = 1.0

        // 開始朗讀文字
        synthesizer.speak(utterance)
    }

    func listAvailableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }

}
