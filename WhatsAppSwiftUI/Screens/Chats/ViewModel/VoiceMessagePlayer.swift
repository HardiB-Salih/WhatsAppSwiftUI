//
//  VoiceMessagePlayer.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/22/24.
//

import Foundation
import AVFoundation

/// A class that handles the playback of voice messages.
final class VoiceMessagePlayer: ObservableObject {
    
    private var player: AVPlayer?
    private(set) var currentUrl: URL?
    @Published private(set) var playerItem: AVPlayerItem?
    @Published private(set) var playbackState: PlaybackState = .stopped
    @Published private(set) var currentTime = CMTime.zero
    private var currentTimeObserver: Any?
    
    deinit {
        tearDown()
    }
    
    /// Plays a voice message from the specified URL.
    /// - Parameter url: The URL of the voice message to play.
    func play(from url: URL) {
        if let currentUrl = currentUrl, currentUrl == url {
            // Resume Voice Message
            resume()
        } else {
            // Playing Voice Message
            currentUrl = url
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            playbackState = .playing
            observeCurrentPlayerTime()
            observeEndOfPlayback()
        }
    }
    
    /// Pauses the currently playing voice message.
    func pause() {
        player?.pause()
        playbackState = .paused
    }
    
    /// Seeks to the specified time interval in the voice message.
    /// - Parameter timeInterval: The time interval to seek to.
    func seek(to timeInterval: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    // MARK: - Private Methods
    
    /// Resumes the playback of the paused voice message.
    private func resume() {
        if playbackState == .paused || playbackState == .stopped {
            player?.play()
            playbackState = .playing
        }
    }
    
    /// Observes the current player's time and updates `currentTime`.
    private func observeCurrentPlayerTime() {
        currentTimeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1),
                                        queue: DispatchQueue.main,
                                        using: { [weak self] time in
            self?.currentTime = time
        })
    }
    
    /// Observes the end of the playback and stops the player.
    private func observeEndOfPlayback() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem,
                                               queue: .main) { [weak self] _ in
            self?.stop()
        }
    }
    
    /// Stops the playback and resets the player.
    private func stop() {
        player?.pause()
        player?.seek(to: .zero)
        playbackState = .stopped
        currentTime = .zero
    }
    
    /// Removes observers from the player.
    private func removeObservers() {
        if let currentTimeObserver = currentTimeObserver {
            player?.removeTimeObserver(currentTimeObserver)
            self.currentTimeObserver = nil
        }
    }
    
    /// Tears down the player and removes all observers.
    private func tearDown() {
        removeObservers()
        player = nil
        playerItem = nil
        currentUrl = nil
    }
}

extension VoiceMessagePlayer {
    /// Enum representing the playback state of the voice message player.
    enum PlaybackState {
        case stopped, playing, paused
        
        var icon: String {
            return self == .playing ? "pause.fill" : "play.fill"
        }
    }
}
