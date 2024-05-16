//
//  BubblePhotoView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct BubblePhotoView: View {
    let item : MessageItem
    
    var body: some View {
        
        HStack {
            if item.direction == .sent { Spacer() }
            
            HStack {
                if item.direction == .sent { shareButton() }
                messageImageView()
                    .overlay(playButton().opacity(item.type == .video ? 1 : 0))
                    
                if item.direction == .received { shareButton() }
            }
            
            
            if item.direction == .received { Spacer() }

        }
    }
    
    private func playButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "play.fill")
                .foregroundStyle(.white)
                .padding()
                .background(.thinMaterial)
                .clipShape(Circle())
        }

    }
    
    private func messageImageView() -> some View {
        VStack (alignment: .leading, spacing: 0){
            Image(.stubImage0)
                .resizable()
                .scaledToFill()
                .frame(width: 220, height: 180)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemGray6)))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.systemGray4), lineWidth: 1.0)
                )
                .padding(5)
                .overlay(alignment: .bottomTrailing, content: {
                    timestampMessage()
                })
            
            Text(item.text)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(width: 220)
        }
        .background(item.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
        .applyTail(item.direction)
    }
    
    private func timestampMessage() -> some View {
        
        HStack (spacing: 4){
            Text("5:40 PM")
                .font(.footnote)
            Image("seen")
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .scaledToFit()
        }
        .padding(4)
        .padding(.horizontal, 4)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(10)
    }
    
    
    private func shareButton() -> some View {
        Button(action: {}, label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10)
                .foregroundStyle(.white)
                .background(Color(.systemGray2))
                .clipShape(Circle())
                
        })
    }
}


#Preview {
    BubblePhotoView(item: .sentPlaceholder)
}
