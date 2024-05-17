//
//  ChatPartnerPickerViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

enum ChannelCreationRoute {
    case addGroupChatMenmbers
    case setUpGroupChat
}

final class ChatPartnerPickerViewModel: ObservableObject {
    /// add more that one navigation from one Navigation Stack
    @Published var navStack = [ChannelCreationRoute]()
    
    @Published var selectedChatPartner = [UserItem]()
    
    var showSelectedUser : Bool {
        return !selectedChatPartner.isEmpty
    }
    
    
    
    //MARK: - Public Methods
    func handleItemSelection(_ user: UserItem) {
        if isUserSelected(user) {
            // deselecte
            guard let index = selectedChatPartner.firstIndex(where: { $0.uid == user.uid}) else { return }
            selectedChatPartner.remove(at: index)
        } else {
            // select
            selectedChatPartner.append(user)
        }
    }
     
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartner.contains { $0.uid == user.uid }
        return isSelected
    }
}
