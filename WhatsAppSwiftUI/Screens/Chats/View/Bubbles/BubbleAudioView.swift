//
//  BubbleAudioView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct BubbleAudioView: View {
    let item: MessageItem
    @State private var sliderValue: Double = 0
    @State private var sliderRange: ClosedRange<Double> = 0...20
//    @State private var sliderRange: (Double, Double) = (0, 20)

    
    var body: some View {
        
        HStack (alignment: .bottom, spacing: 5){
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl ,size: .xxSmall)
            }
            
            if item.direction == .sent { timestampTextView() }
            
            HStack {
                playButton()
                
                customSlider()
                
                
                Text("04:00")
                    .foregroundStyle(Color(.systemGray))
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
        
    }
    
    private func customSlider() -> some View {
        CustomSlider(value: $sliderValue, range: sliderRange) { modifiers in
            ZStack {
                Color(.systemGray).cornerRadius(3).frame(height: 6).modifier(modifiers.trackLeading)
                Color(.systemGray5).cornerRadius(3).frame(height: 6).modifier(modifiers.trackTrailing)
                Circle().fill(.white).overlay { Circle().stroke(Color(.systemGray5), lineWidth: 1) }
                    .modifier(modifiers.thumb)
            }
        }.frame(height: 20)
    }
    
    private func playButton() -> some View {
        Button(action: {}, label: {
            Image(systemName: "play.fill")
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

#Preview {
    
    ScrollView {
        BubbleAudioView(item: .receivedPlaceholder)
        BubbleAudioView(item: .sentPlaceholder)

    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
}

