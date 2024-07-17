//
//  NewGroupSetUpScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import SwiftUI

struct NewGroupSetUpScreen: View {
    @State private var channelName = ""
    @ObservedObject var viewModel : ChatPartnerPickerViewModel
    @Environment(\.dismiss) private var dismiss

    var onCreate: (_ newChaneel: ChannelItem) -> Void
    
    var body: some View {
        List {
            Section {
                channelSetUpHeaderView()
            }
            
            Section {
                Text("Disappearing Messages")
                Text("Group Permissions")
            }
            
            Section {
                SelectedChatPartnerView(users: viewModel.selectedChatPartner) { user in
                    viewModel.handleItemSelection(user)
                }
            } header: {
                
                let count = viewModel.selectedChatPartner.count
                let maxCount = ChannelConstants.maxGroupParticpants
                Text("Particpants: \(count) of \(maxCount)")
            }.listRowBackground(Color.clear)
            
             
        }
        .navigationTitle("New Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            topBarTrailing()
        }
    }
    
    

    private func channelSetUpHeaderView() -> some View {
        HStack {
            Image(systemName: "camera.fill")
                .padding()
                .foregroundStyle(.white)
                .background(Color(.systemGray3))
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color(.systemGray2), lineWidth: 1.0)
                }
            
            TextField("",
                      text: $channelName,
                      prompt: Text("Group Name (optional)"),
                      axis: .vertical)
        }
    }
}


extension NewGroupSetUpScreen {
    @ToolbarContentBuilder
    func topBarTrailing() -> some ToolbarContent {
        ToolbarItem( placement: .topBarTrailing) {
            Button("Create") {
                if viewModel.isDirectChannel {
                    guard let chatPartner = viewModel.selectedChatPartner.first else { return }
                    viewModel.createDirectChannel(chatPartner, completion: onCreate)
                } else {
                    print(channelName)
                    viewModel.createGroupChannel(channelName, completion: onCreate)
                }
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

//#Preview {
//    NavigationStack {
//        NewGroupSetUpScreen(viewModel: ChatPartnerPickerViewModel()) { _ in
//            
//        }
//    }
//}
