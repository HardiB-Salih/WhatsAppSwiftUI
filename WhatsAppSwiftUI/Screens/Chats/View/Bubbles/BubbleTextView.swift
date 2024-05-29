//
//  BubbleTextView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct BubbleTextView: View {
    let item: MessageItem
    
    var body: some View {
        HStack (alignment: .bottom, spacing: 5){
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl ,size: .xxSmall)
            }
            
            if item.direction == .sent { timestampTextView() }
            
            Text(item.text)
                .padding(10)
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
    
    private func timestampTextView() -> some View {
        HStack {
            Text(item.timestamp.formatToTime)
                .font(.footnote)
                .foregroundStyle(.gray)
            
            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
                    .scaledToFit()
                    .foregroundStyle(Color(.systemBlue))
            }
        }
    }
}

#Preview {
    ScrollView {
        BubbleTextView(item: .sentPlaceholder)
        BubbleTextView(item: .receivedPlaceholder)

    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
}
