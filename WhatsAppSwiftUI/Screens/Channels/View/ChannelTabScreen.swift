//
//  ChannelTabScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct ChannelTabScreen: View {
    @State private var searchText = ""
    @State private var showChatPartnerPickerScreen = false
    
    var body: some View {
        NavigationStack {
            List {
                archivedButton()
            
                ForEach(0.to(4), id: \.self) { _ in
                    NavigationLink {
                        ChatRoomScreen()
                    } label: {
                        ChannelItemView(messageType: .photoMessage)
                    }
                }
                
                inboxFooterView()
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Chats")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
            }.sheet(isPresented: $showChatPartnerPickerScreen) {
                ChatPartnerPickerScreen()
            }
        }
    }
    
    private func archivedButton() -> some View {
        Button("Archived", systemImage: "archivebox.fill", action: {})
            .bold()
            .foregroundStyle(Color(.systemGray))
            .padding()
    }
    
    private func inboxFooterView() -> some View {
        HStack {
            Image(systemName: "lock.fill")
            
            
            (
                Text("Your personal messages are")
                +
                Text("end-to-end encrypted")
                    .foregroundStyle(.link)
            )
        }
        .font(.caption)
        .foregroundStyle(.gray)
        .padding(.horizontal)
    }
    
}

#Preview {
    ChannelTabScreen()
}

extension ChannelTabScreen {
        @ToolbarContentBuilder
        private func leadingNavItem()-> some ToolbarContent {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Button(action: {}, label: {
                        Label("Sellect Chats", systemImage: "checkmark.circle")
                    })
                    
                } label: {
                    Image(systemName: "ellipsis.circle").tint(.black)
                }
            }
        }
        
        @ToolbarContentBuilder
        private func trailingNavItem()-> some ToolbarContent {
            ToolbarItemGroup(placement: .topBarTrailing) {
                aiButton()
                cameraButton()
                newChatButton()
            }
        }
    
    private func aiButton() -> some View {
        Button("", image: .circle, action: { })
    }
    
    private func cameraButton() -> some View {
        Button("", systemImage: "camera", action: {}).tint(.black)

    }
    
    private func newChatButton() -> some View {
        Button("", image: .plus, action: { showChatPartnerPickerScreen.toggle() })
        
        
    }
    
}
