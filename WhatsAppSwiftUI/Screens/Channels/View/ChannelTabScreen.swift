//
//  ChannelTabScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct ChannelTabScreen: View {
    @State private var searchText = ""
    @StateObject private var viewModel = ChannelTabViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navRoutes) {
            List {
                archivedButton()
            
                ForEach(viewModel.channels) { channel in
                    Button {
                        viewModel.navRoutes.append(.chatRoom(channel))
                    } label: {
                        ChannelItemView(messageType: .photoMessage, channel: channel)
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
            }
            .navigationDestination(for: ChannelTabRouses.self, destination: { route in
                destinationView(for: route)
            })
            .sheet(isPresented: $viewModel.showChatPartnerPickerScreen) {
                // Finally Require the closer so we can do more action
                ChatPartnerPickerScreen( onCreate: viewModel.onNewChannelCreattion )
            }
            .navigationDestination(isPresented: $viewModel.navigateToChatRoom) {
                if let newChannel = viewModel.newChannel {
                    ChatRoomScreen(channel: newChannel)
                }
                
            }
        }
    }
    
    @ViewBuilder
    private func destinationView( for route: ChannelTabRouses) -> some View {
        switch route {
        case .chatRoom(let channel):
            ChatRoomScreen(channel: channel)
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
        Button("", image: .plus, action: { viewModel.showChatPartnerPickerScreen = true })
        
        
    }
    
}
