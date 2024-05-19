//
//  ChannelItemView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct ChannelItemView: View {
    let messageType : MessageType
    let channel: ChannelItem
    var body: some View {
        HStack (alignment: .top){
            CircularProfileImageView(channel, size: .medium)
            
            
            VStack(alignment: .leading, spacing: 5) {
                Text(channel.title)
                    .lineLimit(1)
                    .fontWeight(.bold)
                
                Text(channel.lastMessage)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
                    
//                HStack(alignment: .center, spacing: 4) {
//                    Image(systemName: messageType.icon)
//                    Text(messageType.title)
//                }.foregroundStyle(Color(.systemGray2))
            }
            
            Spacer()
            
            Text(channel.lastMessageTimestamp.dayOrTimeRepresentaion)
                .foregroundStyle(Color(.systemGray2))
        }
    }
}

extension ChannelItemView {
     enum MessageType : String {
        case voiceMessage, photoMessage
        
        
        fileprivate var title: String {
            switch self {
            case .voiceMessage:
                return "Voice Message"
            case .photoMessage:
                return "Photo Message"
            }
        }
        fileprivate var icon: String {
            switch self {
            case .voiceMessage:
                return "mic.fill"
            case .photoMessage:
                return "photo"
            }
        }
    }
}

#Preview {
    ChannelItemView(messageType: .voiceMessage, channel: .placeholder)
}
