//
//  VideoMessagePlayer.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/22/24.
//

import Foundation
import AVFoundation
import UIKit

/// A class that handles the playback of video messages.
final class VideoMessagePlayer: ObservableObject {
    
    private var player: AVPlayer?
    private var currentUrl: URL?
    private var playerItem: AVPlayerItem?
    private var playbackState: PlaybackState = .stopped
    private var currentTime = CMTime.zero
    private var currentTimeObserver: Any?
    private var playerLayer: AVPlayerLayer?
    
    deinit {
        tearDown()
    }
    
    /// Plays a video message from the specified URL.
    /// - Parameter url: The URL of the video message to play.
    /// - Parameter view: The UIView where the video will be displayed.
    func play(from url: URL, on view: UIView) {
        if let currentUrl = currentUrl, currentUrl == url {
            // Resume Video Message
            resume()
        } else {
            // Playing Video Message
            currentUrl = url
            let playerItem = AVPlayerItem(url: url)
            self.playerItem = playerItem
            player = AVPlayer(playerItem: playerItem)
            setupPlayerLayer(on: view)
            player?.play()
            playbackState = .playing
            observeCurrentPlayerTime()
            observeEndOfPlayback()
        }
    }
    
    /// Pauses the currently playing video message.
    func pause() {
        player?.pause()
        playbackState = .paused
    }
    
    /// Seeks to the specified time interval in the video message.
    /// - Parameter timeInterval: The time interval to seek to.
    func seek(to timeInterval: TimeInterval) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: timeInterval, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    // MARK: - Private Methods
    
    /// Sets up the player layer to display video on the specified view.
    /// - Parameter view: The UIView where the video will be displayed.
    private func setupPlayerLayer(on view: UIView) {
        playerLayer?.removeFromSuperlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
    }
    
    /// Resumes the playback of the paused video message.
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
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Tears down the player and removes all observers.
    private func tearDown() {
        removeObservers()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        playerItem = nil
        currentUrl = nil
    }
}

extension VideoMessagePlayer {
    /// Enum representing the playback state of the video message player.
    enum PlaybackState {
        case stopped, playing, paused
    }
}
