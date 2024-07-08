//
//  ChannelItemView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct ChannelItemView: View {
    let channel: ChannelItem
    var body: some View {
        HStack (alignment: .top){
            CircularProfileImageView(channel, size: .medium)
            
            
            VStack(alignment: .leading, spacing: 5) {
                Text(channel.title)
                    .lineLimit(1)
                    .fontWeight(.bold)
                
                HStack (spacing: 0){
                    Image(systemName: channel.lastMessageType.iconName)
                        .imageScale(.small)
                        .foregroundStyle(.gray)
                        .padding(.trailing, 4)
                    
                    Text(channel.previewMessage)
                        .lineLimit(2)
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            Text(channel.lastMessageTimestamp.dayOrTimeRepresentaion)
                .foregroundStyle(Color(.systemGray2))
        }
    }
}

#Preview {
    ChannelItemView( channel: .placeholder)
}
