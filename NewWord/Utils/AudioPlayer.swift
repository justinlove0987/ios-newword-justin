//
//  AudioPlayer.swift
//  NewWord
//
//  Created by 曾柏楊 on 2024/8/15.
//

import Foundation
import AVFoundation

protocol AudioPlayerDelegate: AnyObject {
    func audioPlayer(_ player: AudioPlayer, didUpdateToMarkName markName: String)
    func audioPlayerDidPause(_ player: AudioPlayer)
    func audioPlayerDidStop(_ player: AudioPlayer)
    func audioPlayerDidStartPlaying(_ player: AudioPlayer) // 新增方法
}

enum AudioPlayerState {
    case notPlayed
    case playing
    case paused
}

class AudioPlayer {
    private var audioPlayer: AVAudioPlayer?
    
    weak var delegate: AudioPlayerDelegate?
    
    // 表示音頻播放器的當前狀態
    private(set) var state: AudioPlayerState = .notPlayed
    
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
        state = .playing
        delegate?.audioPlayerDidStartPlaying(self) // 通知代理音頻開始播放
    }

    // 停止音頻
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0 // 重置播放時間到開始位置
        state = .notPlayed
        delegate?.audioPlayerDidStop(self) // 通知代理音頻已停止
    }

    // 暫停音頻
    func pause() {
        audioPlayer?.pause()
        state = .paused
        delegate?.audioPlayerDidPause(self) // 通知代理音頻已暫停
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
        state = .playing
        
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
                        
                        delegate?.audioPlayer(self, didUpdateToMarkName: timepoint.markName)
                        
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
