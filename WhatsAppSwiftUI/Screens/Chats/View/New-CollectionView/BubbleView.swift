//
//  BubbleView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 7/6/24.
//

import SwiftUI

struct BubbleView: View {
    let message: MessageItem
    let channel: ChannelItem
    let isNewDay: Bool
    let showSenderName: Bool
    
    var body: some View {
        VStack (alignment:.leading, spacing: 0){
            if isNewDay { newDayTimestamp().padding() }
            if showSenderName { senderName() }
            composeDynamicBubbleView()
        }
    }
}


extension BubbleView {
    //MARK: Rest Of Bubble
    @ViewBuilder
    private func composeDynamicBubbleView() -> some View {
        switch message.type {
        case .text:
            BubbleTextView(item: message)
        case .photo, .video:
            BubblePhotoView(item: message)
        case .audio:
            BubbleAudioView(item: message)
        case .admin(let adminType):
            switch adminType {
            case .channelCreation:
                newDayTimestamp().padding()
                ChannelCreationTextView()
                if channel.isGroupChat {
                    AdminMessageTextView(channel: channel)
                        .padding(.top, 8)
                }
            default :
                Text("Unknown")
            }
        }
    }
    
    //MARK: new Day Timestamp
    private func newDayTimestamp() -> some View {
        Text(message.timestamp.relativeDateString)
            .font(.caption)
            .bold()
            .padding(.vertical, 3)
            .padding(.horizontal)
            .background(.whatsAppGray)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
        
    }
    
    private func senderName() -> some View {
        Text(message.sender?.username ?? "Unknown 🤷")
            .lineLimit(1)
            .foregroundStyle(.gray)
            .font(.footnote)
            .padding(.bottom, 2)
            .padding(.horizontal)
            .padding(.leading, 20)
    }
}

#Preview {
    BubbleView(message: .receivedPlaceholder, channel: .placeholder, isNewDay: false, showSenderName: false)
}


