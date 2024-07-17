//
//  ChatPartnerPickerScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct ChatPartnerPickerScreen: View {
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatPartnerPickerViewModel()
    
    // send back data to previus page
    var onCreate: (_ newChaneel: ChannelItem) -> Void
    
    var body: some View {
        NavigationStack(path: $viewModel.navStack) {
            List {
                ForEach(ChatPartnerPickerOption.allCases) { item in
                    HeaderItemView(item: item) {
                        guard  item == ChatPartnerPickerOption.newGroup else {return }
                        viewModel.navStack.append(.groupPartnerPicker)
                    }
                }
                
                //MARK: List Of User and creating direct Chat
                Section {
                    ForEach(viewModel.users) {  user in
                        ChatPartnerRowView(user: user)
                            .onTapGesture {
                                viewModel.createDirectChannel(user, completion: onCreate)
                            }
                    }
                } header: {
                    Text("Contacts on WhatsApp")
                        .textCase(nil)
                        .bold()
                }
                
                if viewModel.isPaginatable {
                    loadMoreUserView()
                }
                
            }
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search name or number")
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ChannelCreationRoute.self,
                                   destination: { route in
                destinationView(for: route)
            })
            .alert(isPresented: $viewModel.errorState.showError) {
                Alert(title: Text("Uh Oh 🤷"),
                      message: Text(viewModel.errorState.errorMessage),
                      dismissButton: .default(Text("OK"))
                )
            }
            
            
            
            .toolbar {
                trailingNavItem()
            }
            .onAppear {
                viewModel.deSelectAllChatPartners()
            }
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


extension ChatPartnerPickerScreen {
    /// user this to add more than one scree in the list of the navStack
    @ViewBuilder
    private func destinationView(for route: ChannelCreationRoute) -> some View {
        switch route {
        case .groupPartnerPicker:
            GroupPartnerPickerScreen(viewModel: viewModel)
        case .setUpGroupChat:
            NewGroupSetUpScreen(viewModel: viewModel, onCreate: onCreate)
        }
    }
}

extension ChatPartnerPickerScreen {
    @ToolbarContentBuilder
    private func trailingNavItem()-> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: { dismiss() }, label: {
                Image(systemName: "xmark")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.darkGray))
                    .padding(8)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1.0))
            })
        }
    }
}

extension ChatPartnerPickerScreen {
    private struct HeaderItemView: View {
        let item : ChatPartnerPickerOption
        let action: () ->Void
        var body: some View {
            Button{
                action()
            } label: {
                HStack {
                    Image(systemName: item.iconName)
                        .font(.footnote)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1.0))
                    Text(item.title)
                }
                .foregroundStyle(.black)
                
            }
        }
    }
}

enum ChatPartnerPickerOption: String, CaseIterable, Identifiable {
    case newGroup = "New Group"
    case newContact = "New Contact"
    case newCommunities = "New Communities"
    
    var id : String {
        return self.rawValue
    }
    
    var title: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .newGroup:
            return "person.2.fill"
        case .newContact:
            return "person.fill.badge.plus"
        case .newCommunities:
            return "person.3.fill"
        }
    }
}




//#Preview {
//    ChatPartnerPickerScreen  { channel in }
//}
