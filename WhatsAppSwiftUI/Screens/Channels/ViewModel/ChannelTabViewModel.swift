//
//  ChannelTabViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import Foundation
import Firebase

enum ChannelTabRouses: Hashable {
    case chatRoom(_ channel: ChannelItem)
}

final class ChannelTabViewModel: ObservableObject {
    @Published var navRoutes = [ChannelTabRouses]()
    
    
    @Published var navigateToChatRoom = false
    @Published var newChannel : ChannelItem?
    @Published var showChatPartnerPickerScreen = false
    @Published var channels = [ChannelItem]()
    
    // We build This dictionary fo we do not get the doplicate
    typealias ChannelId = String
    @Published var channelDictionary : [ChannelId: ChannelItem] = [:]

    init() {
        fetchCurrentUserChannels()
    }
    func onNewChannelCreattion(_ channel: ChannelItem) {
        showChatPartnerPickerScreen = false
        newChannel = channel
        navigateToChatRoom = true
    }
    
    
    private func fetchCurrentUserChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // Observe for any changes happning in Firebase Database
        FirebaseConstants.UserChannelsRef.child(currentUid).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String : Any] else { return }
            dict.forEach { key, value in
                let channelId = key
                self?.getChannel(with: channelId)
            }
        } withCancel: { error in
            print("🙀 Faild to get current user's channelIds: \(error.localizedDescription)")
        }

    }
    
    
    private func getChannel(with channelId: String) {
        FirebaseConstants.ChannelsRef.child(channelId).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String : Any] else { return }
            var channel = ChannelItem(dict)
            self?.getChannelMebers(channel: channel) { members in
                channel.members = members
                self?.channelDictionary[channelId] = channel
                self?.reloadData()
//                self?.channels.append(channel)
                print("💿 Channel \(channel.title)")
            }
        } withCancel: { error in
            print("🙀 Faild to get Channel for id \(channelId): \(error.localizedDescription)")
        }
    }
    
    
    private func getChannelMebers(channel: ChannelItem, completion: @escaping (_ members: [UserItem]) -> Void){
        // We jst retrive only two member from the members
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //How to filter just a [String or Int or Any] single data
        let channelMemberUids = Array(channel.membersUids.filter { $0 != currentUid }.prefix(2))
        UserServices.getUsers(with: channelMemberUids) { userNode in
            completion(userNode.users)
        }
    }
    
    
    private func reloadData() {
        self.channels = Array(channelDictionary.values)
        self.channels.sort { $0.lastMessageTimestamp > $1.lastMessageTimestamp}
    }
}
