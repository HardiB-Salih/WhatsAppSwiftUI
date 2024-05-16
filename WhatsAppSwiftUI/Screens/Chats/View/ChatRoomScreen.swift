//
//  ChatRoomScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct ChatRoomScreen: View {
    
    @Environment(\.dismiss) var dismiss
    
    init(){
        UIHelperManager.makeNavigationBarOpaque()
    }
    
    var body: some View {
        MessageListView()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }
            .safeAreaInset(edge: .bottom) {
                TextInputArea()
                    .padding(.horizontal)
            }
    }
}

#Preview {
    NavigationStack {
        ChatRoomScreen()
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
            Circle()
                .frame(width: 35, height: 35)
            
            Text("User Name")
                .font(.footnote)
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
