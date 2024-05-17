//
//  UserItem.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import Foundation

// MARK: - User Data Model
struct UserItem: Identifiable, Decodable, Hashable {
    let uid: String
    let username: String
    let email: String
    var bio: String? = nil
    var profileImageUrl: String? = nil
    
    var id: String {
        return uid
    }
    
    var bioUnweappede: String {
        return bio ?? "Hey there! I am using AhatsApp."
    }
    
    static let placeholder = UserItem(uid: "!", username: "HardiB", email: "Hardib@gmail.com")
}

// MARK: - Initialization from Dictionary
extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String? ?? nil
        self.profileImageUrl = dictionary[.profileImageUrl] as? String? ?? nil
    }
}

// MARK: - String Constants
extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageUrl = "profileImageUrl"
}
