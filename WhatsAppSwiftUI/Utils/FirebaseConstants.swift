//
//  FirebaseConstants.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage



enum FirebaseConstants {
    private static let DatabaseRef  = Database.database().reference()
    static let UserRef = DatabaseRef.child("users")
    static let ChannelsRef = DatabaseRef.child("channels")
    static let MessagesRef = DatabaseRef.child("channels-messages")
    static let UserChannelsRef = DatabaseRef.child("uaer_channels")
    static let UserDirectChannelsRef = DatabaseRef.child("uaer_direct_channels")
    
    //MARK: Storage
    static let StorageReference = Storage.storage().reference()
}
