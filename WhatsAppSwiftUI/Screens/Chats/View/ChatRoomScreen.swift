//
//  ChatRoomScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct ChatRoomScreen: View {
    let channel: ChannelItem
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ChatRoomViewModel
    
    init(channel: ChannelItem) {
        UIHelperManager.makeNavigationBarOpaque()
        self.channel = channel
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(channel: channel))
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("chatbackground")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.7)
                .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
            
            MessageListView(viewModel: viewModel)
                .safeAreaInset(edge: .bottom) {
                    TextInputArea(textMessage: $viewModel.textMessage) {
                        viewModel.sendMessageOrAudio()
                    }
                    .padding(.horizontal)
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            leadingNavItem()
            trailingNavItem()
        }
        
        
        
        
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen(channel: .placeholder)
    }
}

extension ChatRoomScreen {
    
    @ToolbarContentBuilder
    private func leadingNavItem()-> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            backButton()
            chatInfo()
        }
    }
    
    private func chatInfo() -> some View {
        HStack {
            CircularProfileImageView(channel, size: .xxSmall)
            
            Text(channel.title.truncated())
                .fontWeight(.semibold)
        }
    }
    
    private func backButton() -> some View {
        Button("", systemImage: "chevron.left", action: {
            dismiss()
        }).tint(.black)
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem()-> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            videoButton()
            phoneButton()
        }
    }
    
    private func videoButton() -> some View {
        Button("", systemImage: "video", action: {}).tint(.black)
    }
    
    private func phoneButton() -> some View {
        Button("", systemImage: "phone", action: {}).tint(.black)
    }
    
}
