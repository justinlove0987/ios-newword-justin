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
    func audioPlayerDidFinishPlaying(_ player: AudioPlayer) // 新增方法
}

enum AudioPlayerState {
    case notPlayed
    case playing
    case paused
}

class AudioPlayer: NSObject {
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer? // 計時器作為屬性
    
    weak var delegate: AudioPlayerDelegate?
    
    // 表示音頻播放器的當前狀態
    private(set) var state: AudioPlayerState = .notPlayed
    
    // 有audioData，載入音頻文件
    var audioData: Data?

    override init() {}
    
    func setupAudioPlayer() {
        guard let audioData else { return }
        
        do {
            self.audioPlayer = try AVAudioPlayer(data: audioData)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.delegate = self
        } catch {
            print("error: \(error)")
        }
        
    }

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
        stopPlaybackTimer()
    }

    // 暫停音頻
    func pause() {
        audioPlayer?.pause()
        state = .paused
        delegate?.audioPlayerDidPause(self) // 通知代理音頻已暫停
        pausePlaybackTimer()
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
        play()
        startPlaybackTimer(with: article)
    }

    
    // 暫停計時器
    private func pausePlaybackTimer() {
        playbackTimer?.invalidate()
    }
    
    // 停止計時器並設為 nil
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    // 用於手動觸發計時器邏輯的方法
    func triggerPlaybackLogic(_ article: FSArticle) {
        handlePlaybackTimer(article: article)
    }
    
    // 啟動計時器
    private func startPlaybackTimer(with article: FSArticle) {
        stopPlaybackTimer() // 停止並清除現有的計時器
                
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            DispatchQueue.main.async {
                self?.handlePlaybackTimer(article: article)
            }
        }
        
        RunLoop.main.add(playbackTimer!, forMode: RunLoop.Mode.common)
    }
    
    private func handlePlaybackTimer(article: FSArticle) {
            guard let player = audioPlayer else { return }
            guard let result = article.ttsSynthesisResult else { return }

            let text = article.text
            let currentTimeInSeconds = roundToOneDecimalPlace(player.currentTime)
            
            for timepoint in result.timepoints {
                let markTime = roundToOneDecimalPlace(timepoint.timeSeconds)
                
                if markTime == currentTimeInSeconds && !currentTimeInSeconds.isZero  {
                    if let nsRange = timepoint.range, let _ = Range(nsRange, in: text) {
                        delegate?.audioPlayer(self, didUpdateToMarkName: timepoint.markName)
                    } else {
                        print("Invalid range")
                    }
                }
            }
            
            if !isPlaying() {
                stopPlaybackTimer()
            }
        }
    
    func roundToOneDecimalPlace(_ value: Double) -> Double {
        return round(value * 10) / 10
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 通知代理音頻播放完畢
        delegate?.audioPlayerDidFinishPlaying(self)
        stopPlaybackTimer() // 播放完畢後停止計時器
        state = .notPlayed
    }
}
