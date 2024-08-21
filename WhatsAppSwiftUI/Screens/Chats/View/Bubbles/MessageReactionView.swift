//
//  MessageReactionView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 8/21/24.
//

import SwiftUI

struct MessageReactionView: View {
    let message : MessageItem
    private var emojis: [String] {
        return message.reactions.map { $0.key }
    }
    private var emojiCounts: Int {
        let stats = message.reactions.map { $0.value}
        return stats.reduce(0, +)
    }
    var body: some View {
        if message.hasReaction {
            HStack (spacing: 2){
                ForEach(emojis, id: \.self) {emoji in
                    Text(emoji)
                        .fontWeight(.semibold)
                }
                if emojiCounts > 2 {
                    Text(emojiCounts.description)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 2)
                }
            }
            .font(.footnote)
            .padding(4)
            .padding(.horizontal, 2)
            .background(Capsule().fill(.thinMaterial))
            .overlay(
                Capsule()
                    .stroke(message.backgroundColor, lineWidth: 2)
            
            )
            .shadow(color: message.backgroundColor.opacity(0.2), radius: 5, x: 0, y: 5)
        }
    }
}

#Preview {
    ZStack{
        Color(.gray).ignoresSafeArea()
        MessageReactionView(message: .receivedPlaceholder)
    }
}
