//
//  BubbleAudioView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI
import AVKit

struct BubbleAudioView: View {
    let item: MessageItem
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...20
    @EnvironmentObject private var voiceMessagePlayer: VoiceMessagePlayer
//    @State private var sliderRange: (Double, Double) = (0, 20)
    @State private var playbackState: VoiceMessagePlayer.PlaybackState = .playing
    @State private var playbackTime = "00:00"
    @State private var isDraggingSlider = false
    
    var body: some View {
        
        HStack (alignment: .bottom, spacing: 5){
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl ,size: .xxSmall)
            }
            
            if item.direction == .sent { timestampTextView() }
            
            HStack {
                playButton()
                
                customSlider()
                
                if playbackState == .stopped {
                    Text(item.audioDurationInString)
                        .foregroundStyle(Color(.systemGray))
                } else {
                    Text(playbackTime)
                        .foregroundStyle(Color(.systemGray))
                }
                
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(5)
            .background(item.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .applyTail(item.direction)
            
            if item.direction == .received { timestampTextView() }
        }
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.traillingPadding)
        .onReceive(voiceMessagePlayer.$playbackState, perform: { state in
            observePlaybackState(state)
        })
        .onReceive(voiceMessagePlayer.$currentTime) { currentTime in
            guard voiceMessagePlayer.currentUrl?.absoluteString == item.audioURL else { return }
            listen(to: currentTime)
        }
        .onReceive(voiceMessagePlayer.$playerItem) { playerItem in
            guard voiceMessagePlayer.currentUrl?.absoluteString == item.audioURL else { return }
            guard let audioDuration = item.audioDuration else { return }
            sliderRange = 0...audioDuration
        }
        
    }
    
    private func customSlider() -> some View {
        CustomSlider(value: $sliderValue, range: sliderRange, onEditingChanged: { editing in
            isDraggingSlider = editing
            if editing {
                voiceMessagePlayer.seek(to: sliderValue)
            }
        }) { modifiers in
            ZStack {
                Color(.systemGray).cornerRadius(3).frame(height: 6).modifier(modifiers.trackLeading)
                Color(.systemGray5).cornerRadius(3).frame(height: 6).modifier(modifiers.trackTrailing)
                Circle().fill(.white).overlay { Circle().stroke(Color(.systemGray5), lineWidth: 1) }
                    .modifier(modifiers.thumb)
            }
        }.frame(height: 20)
    }
    
    private func playButton() -> some View {
        Button(action: {
            handlePlayVoiceMessage()
        }, label: {
            Image(systemName: playbackState.icon)
                .padding(10)
                .foregroundStyle(item.direction == .received ? .white : .black)
                .background(item.direction == .received ? Color(.systemGreen) : .white)
                .clipShape(Circle())
        })
    }
    
    private func timestampTextView() -> some View {
        Text("3:35 PM")
            .font(.footnote)
            .foregroundStyle(.gray)
    }
    
    
}

//MARK: Voice Message Player Playback States
extension BubbleAudioView {
    private func handlePlayVoiceMessage() {
        if playbackState == .stopped || playbackState == .paused {
            guard let audioURLString = item.audioURL, let voiceMessageURL = URL(string: audioURLString) else { return }
            voiceMessagePlayer.play(from: voiceMessageURL)
        } else {
            voiceMessagePlayer.pause()
        }
        
    }
    
    private func observePlaybackState(_ state: VoiceMessagePlayer.PlaybackState) {
        if state == .stopped {
            playbackState = .stopped
            sliderValue = 0
        } else {
            guard voiceMessagePlayer.currentUrl?.absoluteString == item.audioURL else { return }
            playbackState = state
        }
    }
    
    private func listen(to currentTime: CMTime) {
        guard !isDraggingSlider else { return }
        playbackTime = currentTime.seconds.formatElapsedTime
        sliderValue = currentTime.seconds
    }
}

#Preview {
    
    ScrollView {
        BubbleAudioView(item: .receivedPlaceholder)
        BubbleAudioView(item: .sentPlaceholder)

    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
    .environmentObject(VoiceMessagePlayer())
}

