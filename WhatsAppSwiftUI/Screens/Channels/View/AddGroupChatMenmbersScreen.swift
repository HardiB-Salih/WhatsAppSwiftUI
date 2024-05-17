//
//  AddGroupChatMenmbersScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct AddGroupChatMenmbersScreen: View {
    @ObservedObject var viewModel : ChatPartnerPickerViewModel
    @State private var searchText = ""
    var body: some View {
        List {
            
            if viewModel.showSelectedUser {
                ForEach(viewModel.selectedChatPartner) { user in
                    selectedChatPartner(user: user)
                }
            }
            
            Section {
                ForEach([UserItem.placeholder]) { user in
                    Button(action: {
                        viewModel.handleItemSelection(user)
                    }, label: {
                        chatPartnerRowView(user: .placeholder)
                    })
                }
            }
            
        }
        .animation(.easeInOut, value: viewModel.showSelectedUser)
        .searchable(text: $searchText,
                     placement: .navigationBarDrawer(displayMode: .always),
                     prompt: "Search name or number")
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
    
    private func selectedChatPartner(user: UserItem) -> some View {
        VStack(alignment: .center) {
            Circle().frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .imageScale(.small)
                        .foregroundStyle(.black)
                        .padding(3)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .offset(x: 3, y: -3)
                        .onTapGesture {
                            viewModel.handleItemSelection(user)
                        }
                }
            Text("User1")
                .font(.footnote)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    NavigationStack {
        AddGroupChatMenmbersScreen(viewModel: ChatPartnerPickerViewModel())
    }
}
