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
    
    var body: some View {
        NavigationStack(path: $viewModel.navStack) {
            List {
                ForEach(ChatPartnerPickerOption.allCases) { item in
                    HeaderItemView(item: item)
                        .onTapGesture {
                            switch item.title {
                            case "New Group":
                                viewModel.navStack.append(.addGroupChatMenmbers)
                            default:
                                break
                                
                            }
                            
                        }
                }
                
                Section {
                    ForEach(0.to(12), id: \.self) { _ in
                        ChatPartnerRowView(user: .placeholder)
                    }
                } header: {
                    Text("Contacts on WhatsApp")
                        .textCase(nil)
                        .bold()
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
            .toolbar {
                trailingNavItem()
            }
        }
    }
    
    
}

extension ChatPartnerPickerScreen {
    @ViewBuilder
    private func destinationView(for route: ChannelCreationRoute) -> some View {
        switch route {
        case .addGroupChatMenmbers:
            AddGroupChatMenmbersScreen(viewModel: viewModel)
        case .setUpGroupChat:
            Text("SET UP GROUP CHAT")
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
        var body: some View {
            Button{
                // Add the info
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




#Preview {
    ChatPartnerPickerScreen()
}
