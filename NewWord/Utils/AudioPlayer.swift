//
//  AudioPlayer.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/15.
//

import Foundation
import AVFoundation

protocol AudioPlayerDelegate: AnyObject {
    func audioPlayer(_ player: AudioPlayer, didUpdateToRange range: NSRange)
}

class AudioPlayer {
    private var audioPlayer: AVAudioPlayer?
    
    weak var delegate: AudioPlayerDelegate?
    
    // 有audioData，載入音頻文件
    var audioData: Data? {
        didSet {
            do {
                guard let audioData else { return }
                
                self.audioPlayer = try AVAudioPlayer(data: audioData)
                self.audioPlayer?.prepareToPlay()
            } catch {
                print("Error initializing audio player: \(error.localizedDescription)")
            }
        }
    }

    init() {}

    // 播放音頻
    func play() {
        audioPlayer?.play()
    }

    // 停止音頻
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0 // 重置播放時間到開始位置
    }

    // 暫停音頻
    func pause() {
        audioPlayer?.pause()
    }

    // 調整音量 (0.0 - 1.0)
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }

    // 檢查是否正在播放
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func playAudioWithMarks(_ article: FSArticle) {
        guard let result = article.ttsSynthesisResult else { return }
        
        let text = article.text
        
        audioPlayer?.play()
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }
            
            let currentTimeInSeconds = roundToOneDecimalPlace(player.currentTime)
            
            for timepoint in result.timepoints {
                
                // let markName = timepoint.markName
                let markTime = roundToOneDecimalPlace(timepoint.timeSeconds)
                
                if markTime == currentTimeInSeconds && !currentTimeInSeconds.isZero  {
                    if let nsRange = timepoint.range, let range = Range(nsRange, in: text) {
                        // let substring = text[range]
                        
                        delegate?.audioPlayer(self, didUpdateToRange: nsRange)
                        
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
    }
    
    func roundToOneDecimalPlace(_ value: Double) -> Double {
        return round(value * 10) / 10
    }
}
