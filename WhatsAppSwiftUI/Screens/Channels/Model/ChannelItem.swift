//
//  ChannelItem.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import Foundation
import Firebase

struct ChannelItem: Identifiable , Hashable{
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimestamp: Date
    var membersCount: Int
    var adminUids: [String]
    var membersUids: [String]
    private var thumbnailUrl: String?
    var members: [UserItem]
    let createdBy: String
    
    
    var coverImageUrl: String? {
        if let thumbnailUrl = thumbnailUrl {
            return thumbnailUrl
        }
        
        if !isGroupChat {
            return membersExcludingMe.first?.profileImageUrl
        }
        
        return nil
    }
    
    var isGroupChat : Bool {
        return membersCount > 2
    }
    
    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter { $0.uid != currentUid}
    }
    
    var title: String {
        if let name = name {
            return name
        }
        
        if isGroupChat {
            return groupMemberNames
        } else {
            return membersExcludingMe.first?.username ?? "Unknown"
        }
    }
    
    private var groupMemberNames : String {
//        let membersCount = membersExcludingMe.count
        let membersCount = membersCount - 1
        let fullname: [String] = membersExcludingMe.map { $0.username }
        
        
        if membersCount == 2 {
            // member1 and member2
            return fullname.joined(separator: " and ")
        } else if membersCount > 2 {
            // member1, member2 and 10 other
            let remainingCount = membersCount - 2
            return fullname.prefix(2).joined(separator: ", ") + ", and \(remainingCount) others"
        }
        
        return "Unknown"
    }
    
    
    
    var isCreatedByMe: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return createdBy == currentUid
    }
    
    /// The username of the member who created the item.
    ///
    /// This property searches through the `members` array to find the first member whose `uid` matches the `createdBy` value.
    /// If found, it returns that member's `username`; otherwise, it returns an empty string.
    var creatorName: String {
        return members.first { $0.uid == createdBy }?.username ?? ""
    }
    
    
    var allmemberFetched: Bool {
        return members.count == membersCount
    }
    
    
    static let placeholder: ChannelItem = ChannelItem.init(id: "1", lastMessage: "", creationDate: Date(), lastMessageTimestamp: Date(), membersCount: 2, adminUids: [], membersUids: [], members: [], createdBy: "")
}

extension ChannelItem {
    init(_ dictionary: [String: Any]) {
        self.id = dictionary[.id] as? String ?? ""
        self.name = dictionary[.name] as? String? ?? nil
        self.lastMessage = dictionary[.lastMessage] as? String ?? ""
        self.thumbnailUrl = dictionary[.thumbnailUrl] as? String ?? nil
        
        let creationInterval = dictionary[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationInterval)
        
        let lastMessageInterval = dictionary[.lastMessageTimestamp] as? Double ?? 0
        self.lastMessageTimestamp = Date(timeIntervalSince1970: lastMessageInterval)

        self.membersCount = dictionary[.membersCount] as? Int ?? 0
        self.membersUids = dictionary[.membersUids] as? [String] ?? []
        self.adminUids = dictionary[.adminUids] as? [String] ?? []
        self.members = dictionary[.members] as? [UserItem] ?? []
        
        self.createdBy = dictionary[.createdBy] as? String ?? ""
    }
}


extension String {
    static let id = "id"
    static let name = "name"
    static let lastMessage = "lastMessage"
    static let creationDate = "creationDate"
    static let lastMessageTimestamp = "lastMessageTimestamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let membersUids = "membersUids"
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
    static let createdBy = "createdBy"

}
