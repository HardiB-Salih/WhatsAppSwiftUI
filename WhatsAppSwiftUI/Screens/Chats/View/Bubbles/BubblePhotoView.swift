//
//  BubblePhotoView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI
import Kingfisher

struct BubblePhotoView: View {
    let item : MessageItem
    
    var body: some View {
        
        HStack (alignment: .bottom, spacing: 5){
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageUrl ,size: .xxSmall)
                    .offset(y: 5)
            }
            if item.direction == .sent { Spacer() }
            
            messageImageView()
                .overlay(playButton().opacity(item.type == .video ? 1 : 0))
            
            
            if item.direction == .received { Spacer() }

        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.traillingPadding)
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
            KFImage(item.thumbnailURL)
                .resizable()
                .placeholder({
                    ProgressView()
                })
                .scaledToFill()
                .frame(width: item.imageSize.width, height: item.imageSize.height)
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
            
            if item.text.isNotEmptyOrWhitespaces {
                Text(item.text)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: item.imageSize.width)
            }
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
    ScrollView {
        BubblePhotoView(item: .sentPlaceholder)
        BubblePhotoView(item: .receivedPlaceholder)

    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
}
