//
//  ChatRoomViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import Foundation
import Combine

final class ChatRoomViewModel : ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    
    private var currentUser: UserItem?
    private(set) var channel: ChannelItem
    private var subscritions = Set<AnyCancellable>()
    
    
    init(channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
    }
    
    deinit {
        subscritions.forEach { $0.cancel() }
        subscritions.removeAll()
        currentUser = nil
    }
    
    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink {[weak self] authState in
            switch authState {
            case .loggedIn(let currentUser):
                self?.currentUser = currentUser
                self?.getMessages()
            default:
                break
            }
        }.store(in: &subscritions)
    }
    
    func sendMessageOrAudio() {
        guard let currentUser = currentUser else { return }
        if textMessage.isEmptyOrWhitespaces {
            // Send audio
            print("Send audio")
        } else {
            // Send text message
            MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) { [weak self] in
                print("Message service is sending")
            }
            textMessage = ""
        }
    }
    
    
    private func getMessages() {
        MessageService.getMessages(for: channel) { messages in
            self.messages = messages
            print("message: \(messages.map { $0.text })")
        }
    }
}
