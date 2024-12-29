//
//  ViewModel.swift
//  Player
//
//  Created by Муртазали Магомедов on 05.10.2024.
//

import Foundation
import AVFAudio
import RealmSwift

class ViewModel: ObservableObject {
    
    @ObservedResults(SongModel.self) var songs
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlayed = false
    @Published var currentIndex: Int?
    @Published var currentTime: TimeInterval = 0.0
    @Published var totalTime: TimeInterval = 0.0
    
    var currentSong: SongModel? {
        guard let currentIndex = currentIndex, songs.indices.contains(currentIndex) else {
            return nil
        }
        return songs[currentIndex]
    }
    
    func playAudio(song: SongModel) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: song.data)
            self.audioPlayer?.play()
            isPlayed = true
            totalTime = audioPlayer?.duration ?? 0.0
            if let index = songs.firstIndex(where: { $0.id == song.id }) {
                currentIndex = index
            }
        } catch {
            print("Error is playing audio: \(error.localizedDescription)")
        }
        
    }
    
    func nextSong() {
        guard let currentIndex = currentIndex else { return }
        let nextIndex = currentIndex + 1 < songs.count ? currentIndex + 1 : 0
        playAudio(song: songs[nextIndex])
    }
    
    func backSong() {
        guard let currentIndex = currentIndex else { return }
        let backIndex = currentIndex  > 0 ? currentIndex - 1 : 0
        playAudio(song: songs[backIndex])
    }
    
    func seekAudio(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func updateProgress() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
    }
    
    func playPause() {
        if isPlayed {
            self.audioPlayer?.pause()
        } else {
            self.audioPlayer?.play()
        }
        isPlayed.toggle()
    }
    
    func durationFormater(duration: TimeInterval) -> String {
        let formater = DateComponentsFormatter()
        formater.allowedUnits = [.minute, .second]
        formater.unitsStyle = .positional
        formater.zeroFormattingBehavior = .pad
        return formater.string(from: duration) ?? "00:00"
    }
}
