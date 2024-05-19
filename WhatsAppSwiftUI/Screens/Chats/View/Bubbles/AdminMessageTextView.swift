//
//  AdminMessageTextView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import SwiftUI

struct AdminMessageTextView: View {
    let channel: ChannelItem
    
    var body: some View {
        VStack {
            if channel.isCreatedByMe {
                textView("You created this group. Tap to add\n members")
            } else {
                textView("\(channel.creatorName) created this group.")
                textView("\(channel.creatorName) added you.")

            }
                
        }
        
    }
    
    
    private func textView(_ text: String) -> some View {
        Text(text)
            .multilineTextAlignment(.center)
            .font(.footnote)
            .padding(10)
            .padding(.horizontal, 5)
            .background(.whatsAppWhite)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(.systemGray5), lineWidth: 1.0))
            .shadow(color: Color(.systemGray3).opacity(0.2), radius: 10, x: 0, y: 20)
        
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.6)
        AdminMessageTextView(channel: .placeholder)
    }.ignoresSafeArea()
}
