//
//  GroupPartnerPickerScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct GroupPartnerPickerScreen: View {
    @ObservedObject var viewModel : ChatPartnerPickerViewModel
    @State private var searchText = ""
    var body: some View {
        List {
            
            if viewModel.showSelectedUser {
                SelectedChatPartnerView(users: viewModel.selectedChatPartner) { user in
                    viewModel.handleItemSelection(user)
                }
            }
            
            Section {
                ForEach(viewModel.users) { user in
                    Button(action: {
                        viewModel.handleItemSelection(user)
                    }, label: {
                        chatPartnerRowView(user: user)
                    })
                }
            }
            
            if viewModel.isPaginatable {
                loadMoreUserView()
            }
            
        }
        .animation(.easeInOut, value: viewModel.showSelectedUser)
        .searchable(text: $searchText,
                     placement: .navigationBarDrawer(displayMode: .always),
                     prompt: "Search name or number")
        .toolbar {
            titleView()
            topBarTrailing()
        }
    }
    
    private func chatPartnerRowView(user: UserItem) -> some View {
        ChatPartnerRowView(user: user) {
            let isSelected = viewModel.isUserSelected(user)
            let systemName = isSelected ?  "checkmark.circle.fill" : "circle"
            let imageColor = isSelected ?  Color(.link) : Color(.systemGray2)
            Image(systemName: systemName)
                .imageScale(.large)
                .foregroundStyle(imageColor)
        }
    }
    
    //MARK: loadMoreUser here
    private func loadMoreUserView() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .task {
                await viewModel.fetchUsers()
            }
    }
}


extension GroupPartnerPickerScreen {
    @ToolbarContentBuilder
    private func titleView() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack {
                Text("Add Particpants").bold()
                let count = viewModel.selectedChatPartner.count
                let maxCount = ChannelConstants.maxGroupParticpants
                Text("\(count)/\(maxCount)")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                
            }
        }
    }
    
    @ToolbarContentBuilder
    private func topBarTrailing() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Next") {
                viewModel.navStack.append(.setUpGroupChat)
            }
            .bold()
            .disabled(viewModel.disableNextButton)
        }
    }
}

#Preview {
    NavigationStack {
        GroupPartnerPickerScreen(viewModel: ChatPartnerPickerViewModel())
    }
}
