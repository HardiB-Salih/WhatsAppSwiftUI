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
}
