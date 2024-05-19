//
//  ChatPartnerPickerViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI
import Firebase

enum ChannelCreationRoute {
    case groupPartnerPicker
    case setUpGroupChat
}

enum ChannelConstants {
    static let maxGroupParticpants = 12
}

@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    /// add more that one navigation from one Navigation Stack
    /// all you have to do append the name of route to this navStack
    @Published var navStack = [ChannelCreationRoute]()
    @Published var selectedChatPartner = [UserItem]()
    @Published private(set) var users = [UserItem]()
    @Published var errorState : (showError: Bool, errorMessage: String) = ( false , "Uh Oh" )
    
    private var lastCursor: String?
    
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    
    var showSelectedUser : Bool {
        return !selectedChatPartner.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatPartner.isEmpty
    }
    
    var isPaginatable: Bool {
        return !users.isEmpty
    }
    
    
    private var isDirectChannel: Bool {
        return selectedChatPartner.count == 1
    }
    
    
    //MARK: - Public Methods
    func handleItemSelection(_ user: UserItem) {
        if isUserSelected(user) {
            // deselecte
            guard let index = selectedChatPartner.firstIndex(where: { $0.uid == user.uid}) else { return }
            selectedChatPartner.remove(at: index)
        } else {
            // select
            guard selectedChatPartner.count < ChannelConstants.maxGroupParticpants else {
                let errorMessage = "Sorry, we only allow a maximum of \(ChannelConstants.maxGroupParticpants) Particpants in a group chat."
                showError(errorMessage)
                return
            }
            selectedChatPartner.append(user)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartner.contains { $0.uid == user.uid }
        return isSelected
    }
    
    
    func fetchUsers() async {
        do {
            let userNode = try await UserServices.paginateUser(lastCursor: lastCursor, pageSize: 5)
            var filterdUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            filterdUsers = filterdUsers.filter { $0.uid != currentUid }
            
            self.users.append(contentsOf: filterdUsers)
            self.lastCursor = userNode.currentCursor
            
            print("💿 lastCursor: \(lastCursor ?? "")")
        } catch {
            print("💿 Failed to fetch user in ChatPartnerPickerViewModel")
        }
    }
    
    
    
    func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
    
    
    enum ChannelCreationError: Error {
        case noChatPartner
        case failedToCreateUniqueIds
    }
    
    
    func deSelectAllChatPartners () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
            self.selectedChatPartner.removeAll()
        }
    }
    
    func createDirectChannel(_ chatParttner: UserItem, completion: @escaping (_ newChannel: ChannelItem) -> Void ) {
        selectedChatPartner.append(chatParttner)
        Task {
            // If the Channel Already Exsit get it
            if let channelId = await verifyIfDirectChannelExits(with: chatParttner.uid) {
                let snapshot = try await FirebaseConstants.ChannelsRef.child(channelId).getData()
                let channelDict = snapshot.value as! [String : Any]
                var dirrectChannel = ChannelItem(channelDict)
                dirrectChannel.members = selectedChatPartner
                completion(dirrectChannel)
            } else {
                // Other wise Create this
                let channelCreation = createChannel(nil)
                switch channelCreation {
                case .success(let channel):
                    completion(channel)
                case .failure(let error):
                    showError("Sorry something went wrong while we were tring to create your chat")
                    print("Failed to create a Group Channel: \(error.localizedDescription)")
                }
            }
        }
    }
    
    typealias ChannelID = String
    private func verifyIfDirectChannelExits(with chatPartnerId: String) async -> ChannelID? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannelsRef.child(currentUid).child(chatPartnerId).getData(),
              snapshot.exists()
        
        else { return nil }
        
        let directMessageDict = snapshot.value as! [String: Bool]
        let channelId = directMessageDict.compactMap { $0.key }.first
        return channelId
    }

    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: ChannelItem) -> Void ) {
        let channelCreation = createChannel(groupName)
        switch channelCreation {
        case .success(let channel):
            completion(channel)
        case .failure(let error):
            showError("Sorry something went wrong while we were tring to create your channel chat")
            print("Failed to create a Group Channel: \(error.localizedDescription)")
        }
    }
    
    private func createChannel(_ channelName: String?) -> Result<ChannelItem, Error> {
        guard !selectedChatPartner.isEmpty else { return .failure(ChannelCreationError.noChatPartner)}
        
        guard
            let currentUid = Auth.auth().currentUser?.uid,
            let messageId = FirebaseConstants.MessagesRef.childByAutoId().key,
            let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key else {
            return .failure(ChannelCreationError.failedToCreateUniqueIds )
        }
        
        //Chat
        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue
        
        let timestamp = Date().timeIntervalSince1970
        var membersUids = selectedChatPartner.compactMap { $0.uid }
        membersUids.append(currentUid)
        
        
        var channelDict: [String: Any] = [
            .id: channelId,
            .lastMessage: newChannelBroadcast,
            .creationDate: timestamp,
            .lastMessageTimestamp: timestamp,
            .membersUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid],
            .createdBy: currentUid
        ]
        
        if let newChannelName = channelName, newChannelName.isEmptyOrWhitespaces {
            channelDict[.name] = newChannelName
            print(newChannelName)
        }
        
        //message dictionary
        let messageDict: [String: Any] = [
            .type: newChannelBroadcast,
            .timestamp: timestamp,
            .ownerUid: currentUid
        ]
        
        
        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        FirebaseConstants.MessagesRef.child(channelId).child(messageId).setValue(messageDict)
        
        
        
        
        /// Keeping an index of te channel that a specific user belongs to
        membersUids.forEach { userId in
            /// Keeping an index of te channel that a specific user belongs to
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
        }
        
        /// Making sure that direct channel is unique
        if isDirectChannel {
            let chatPartner = selectedChatPartner[0]
            /// user-direct-channels/currentUid/otherUid/channelId
            FirebaseConstants.UserDirectChannelsRef.child(currentUid).child(chatPartner.uid).setValue([ channelId: true ])
            FirebaseConstants.UserDirectChannelsRef.child(chatPartner.uid).child(currentUid).setValue([ channelId: true ])

        }
        
        
        var newChannelItem = ChannelItem(channelDict)
        newChannelItem.members = selectedChatPartner
        return .success(newChannelItem)
    }
}
