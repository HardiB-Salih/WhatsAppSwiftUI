//
//  MediaAtachmentPreview.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/27/24.
//

import SwiftUI

struct MediaAtachmentPreview: View {
    let mediaAttachments : [MediaAttachment]
    let actionHandler: (_ action: UserAction) -> Void
    
    var body: some View {
        
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
//                audioAttachmentView()
                ForEach(mediaAttachments) { attachment in
                    thumnaleImageView(attachment)
                }
            }
            
        }
        .frame(height: Constant.listHeight)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.systemGray4), lineWidth: 2)
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
    }
    
    private func thumnaleImageView(_ attachment: MediaAttachment) -> some View {
        Button(action: {},
               label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: Constant.imageDimention, height: Constant.imageDimention)
                .clipShape(RoundedRectangle(cornerRadius:12, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    cancelButton()
                }
            
                .overlay {
                    if attachment.type == .video(UIImage(), url: .stubURL) {
                        playButton(attachment: attachment)
                    }
                }
            
        })
    }
    private func cancelButton() -> some View {
        Button(action: {}, label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.small)
                .fontWeight(.semibold)
                .padding(5)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(2)
                .foregroundStyle(Color(.systemGray5))
                .shadow(color: .black.opacity(0.1), radius: 5)
            
        })
    }
    
    private func playButton(_ systemName: String = "play.fill", attachment: MediaAttachment) -> some View {
        Button(action: {
            actionHandler(.play(attachment))
            
        }, label: {
            Image(systemName: systemName)
                .scaledToFit()
                .imageScale(.large)
                .fontWeight(.semibold)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(5)
                .foregroundStyle(Color(.systemGray5))
                .shadow(color: .black.opacity(0.1), radius: 5)
            
        })
    }
    
    
    private func audioAttachmentView(attachment: MediaAttachment) -> some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.green, .green.opacity(0.8), .teal]), startPoint: .topLeading, endPoint: .bottom)
            playButton("mic.fill", attachment: attachment)
                .padding(.bottom, 8)
        }
        .frame(width: Constant.imageDimention * 2, height: Constant.imageDimention)
        
        
        .overlay(alignment: .topTrailing) {
            cancelButton()
        }
        .overlay(alignment: .bottomLeading) {
            Text("mp3 file name here")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 1)
                .background(.thinMaterial)
            
        }
        .clipShape(RoundedRectangle(cornerRadius:12, style: .continuous))
        
        
    }
    
    
}

extension MediaAtachmentPreview {
    enum Constant {
        static let listHeight: CGFloat = 100
        static let imageDimention : CGFloat = 80
    }
    
    enum UserAction {
        case play(_ attachment: MediaAttachment)
    }
}








#Preview {
    ScrollView{
        MediaAtachmentPreview(mediaAttachments: [] ) { _ in
            
        }
    }
    .background(Color.gray)
}
