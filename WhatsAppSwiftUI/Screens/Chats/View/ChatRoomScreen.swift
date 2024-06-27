//
//  ChatRoomScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI
import PhotosUI

struct ChatRoomScreen: View {
    let channel: ChannelItem
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: ChatRoomViewModel
    @StateObject private var voiceMessagePlayer = VoiceMessagePlayer()
    
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
                .photosPicker(isPresented: $viewModel.showPhotoPicker,
                              selection: $viewModel.photoPickerItems,
                              maxSelectionCount: 6,
                              photoLibrary: .shared()
                )
                .safeAreaInset(edge: .bottom) {
                    bottomSafeAreaView()
                        .padding(.horizontal)
                }
        }
        .onDisappear {
            viewModel.voiceRecorderService.tearDown()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            leadingNavItem()
            trailingNavItem()
        }
        .fullScreenCover(isPresented: $viewModel.videoPlayerState.show, content: {
            if let player =  viewModel.videoPlayerState.player {
                MediaPlayerView(player: player) {
                    viewModel.dismissMediaPlayer()
                }
            }
            
        })
        .environmentObject(voiceMessagePlayer)
    }
    
    private func bottomSafeAreaView() -> some View {
        VStack (spacing: 0 ) {
            if viewModel.showPhotoPickerPriview {
                withAnimation(.spring(.smooth)) {
                    MediaAtachmentPreview(mediaAttachments: viewModel.mediaAttachments) { action in
                        viewModel.handlleMediaAttachmentPriview(action)
                    }
                    .padding(.bottom, 8)
                }
            }
            
            TextInputArea(textMessage: $viewModel.textMessage, 
                          isRecording: $viewModel.isRecordingVoiceMessage,
                          elapsedTime: $viewModel.elapsedVoiceMessageTime, 
                          showInnerMic: viewModel.showInnerMic ) { action in
                viewModel.handleInputAreaActions(action)
            }
        }
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

//#Preview {
//    NavigationStack {
//        ChatRoomScreen(channel: .placeholder)
//    }
//}
