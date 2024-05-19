//
//  UserServices.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

/// A service for paginating users from Firebase Realtime Database.
struct UserServices {
    
    
    static func getUsers(with uids: [String], completion: @escaping (UserNode)-> Void ) {
        var users: [UserItem] = []
        
        for uid in uids {
            let query = FirebaseConstants.UserRef.child(uid)
            query.observeSingleEvent(of: .value) { snapshot in
                guard let user = try? snapshot.data(as: UserItem.self) else { return }
                users.append(user)
                if users.count == uids.count {
                    completion(.init(users: users))
                }
            } withCancel: { error in
                completion(.emptyUserNode)
            }
        }
    }
    
    
    
    
    /// Paginate users from Firebase Realtime Database.
    ///
    /// - Parameters:
    ///   - lastCursor: The key of the last user from the previous page. If nil, fetches the first page.
    ///   - pageSize: The number of users to fetch per page.
    /// - Returns: A `UserNode` containing the fetched users and the cursor for the next page.
    /// - Throws: An error if the Firebase query fails.
    static func paginateUser(lastCursor: String?, pageSize: UInt) async throws -> UserNode {
        let mainSnapshot: DataSnapshot
        
        // Initial data fetch if lastCursor is nil
        if lastCursor == nil {
            mainSnapshot = try await FirebaseConstants.UserRef.queryLimited(toLast: pageSize).getData()
        } else {
            // Paginate for more data
            mainSnapshot = try await FirebaseConstants.UserRef
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toLast: pageSize + 1)
                .getData()
        }
        
        // Ensure snapshot data is valid
        guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
              let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyUserNode }
        
        // Map snapshots to UserItem instances
        let users: [UserItem] = allObjects.compactMap { dataSnapshot in
            let userDictionary = dataSnapshot.value as? [String: Any] ?? [:]
            return UserItem(dictionary: userDictionary)
        }
        
        // Handle filtering and cursor setting based on pagination state
        if users.count == mainSnapshot.childrenCount {
            let filteredUsers = lastCursor == nil ? users : users.filter { $0.uid != lastCursor }
            let userNode = UserNode(users: filteredUsers, currentCursor: first.key)
            return userNode
        }
        
        return .emptyUserNode
    }
}

/// Represents a node in the user pagination, containing a list of users and a cursor.
struct UserNode {
    var users: [UserItem]
    var currentCursor: String? // The key of the last user retrieved in the current page.
    
    /// An empty UserNode instance for representing an empty state.
    static let emptyUserNode = UserNode(users: [], currentCursor: nil)
}



//MARK: - Longer Version
//    static func paginateUser(lastCursor: String?, pageSize: UInt) async throws -> UserNode {
//        if lastCursor == nil {
//            // initial data fetch
//            let mainSnapshot = try await FirebaseConstants.UserRef.queryLimited(toLast: pageSize).getData()
//
//            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
//                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyUserNode}
//
//            let users: [UserItem] = allObjects.compactMap { dataSnapshot in
//                let userDictionary = dataSnapshot.value as? [String: Any] ?? [:]
//                return UserItem.init(dictionary: userDictionary)
//            }
//
//            if users.count  == mainSnapshot.childrenCount {
//                let userNode = UserNode(users: users, currentCursor: first.key)
//                return userNode
//            }
//
//            return .emptyUserNode
//
//        } else {
//            // paginate for more data
//            let mainSnapshot = try await FirebaseConstants.UserRef
//                .queryOrderedByKey()
//                .queryEnding(atValue: lastCursor)
//                .queryLimited(toLast: pageSize + 1)
//                .getData()
//
//            guard let first = mainSnapshot.children.allObjects.first as? DataSnapshot,
//                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else { return .emptyUserNode}
//
//            let users: [UserItem] = allObjects.compactMap { dataSnapshot in
//                let userDictionary = dataSnapshot.value as? [String: Any] ?? [:]
//                return UserItem.init(dictionary: userDictionary)
//            }
//
//            if users.count  == mainSnapshot.childrenCount {
//                let filterdUsers = users.filter { $0.uid != lastCursor }
//                let userNode = UserNode(users: filterdUsers, currentCursor: first.key)
//                return userNode
//            }
//
//            return .emptyUserNode
//        }
//    }
