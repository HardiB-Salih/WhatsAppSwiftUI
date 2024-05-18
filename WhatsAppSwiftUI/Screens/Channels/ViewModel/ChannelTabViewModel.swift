//
//  ChannelTabViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import Foundation
final class ChannelTabViewModel: ObservableObject {
    @Published var navigateToChatRoom = false
    @Published var newChannel : ChannelItem?
    @Published var showChatPartnerPickerScreen = false

    func onNewChannelCreattion(_ channel: ChannelItem) {
        showChatPartnerPickerScreen = false
        newChannel = channel
        navigateToChatRoom = true
    }
}
