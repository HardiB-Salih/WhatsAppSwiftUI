//
//  MessageService.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

struct MessageService {
    
    static func sendTextMessage(to channel: ChannelItem, from currentUser: UserItem, _ textMessge: String, onComplete: () -> Void) {
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessagesRef.childByAutoId().key else { return }
        
        let chaneelDictionary: [String: Any] = [
            .lastMessage: textMessge,
            .lastMessageTimestamp: timestamp,
            .lastMessageType: MessageType.text.title
        ]
        
        
        let messageDictionary : [String: Any] = [
            .text: textMessge,
            .type: MessageType.text.title,
            .timestamp: timestamp,
            .ownerUid: currentUser.uid
            
        ]
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(chaneelDictionary)
        FirebaseConstants.MessagesRef.child(channel.id).child(messageId).setValue(messageDictionary)
        onComplete()
    }
    
    static func sendMediaMessage(toChannel channel: ChannelItem, params: MessageUploadParams, completion: @escaping SimpleCompletionHandler) {
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessagesRef.childByAutoId().key else { return }
        
        let chaneelDictionary: [String: Any] = [
            .lastMessage: params.text,
            .lastMessageTimestamp: timestamp,
            .lastMessageType: params.type.title
        ]
        
        var messageDictionary : [String: Any] = [
            .text: params.text,
            .type: params.type.title,
            .timestamp: timestamp,
            .ownerUid: params.ownerUID
        ]
        
        
        //Photo Messages & Video Messages
        messageDictionary[.thumbnailUrl] = params.thumbnailUrl ?? nil
        messageDictionary[.thumbnailWidth] = params.thumbnailWidth ?? nil
        messageDictionary[.thumbnailHeight] = params.thumbnailHeight ?? nil
        messageDictionary[.videoURL] = params.videoUrl ?? nil
        
        //Voice Messages
        messageDictionary[.audioURL] = params.audioURL ?? nil
        messageDictionary[.audioDuration] = params.audioDuration ?? nil
        
        FirebaseConstants.ChannelsRef.child(channel.id).updateChildValues(chaneelDictionary)
        FirebaseConstants.MessagesRef.child(channel.id).child(messageId).setValue(messageDictionary)
        completion()
    }
    
    
    static func getMessages(for channel: ChannelItem, completion: @escaping ([MessageItem])-> Void) {
        FirebaseConstants.MessagesRef.child(channel.id).observe(.value) { snapshot  in
            guard let dict = snapshot.value as? [String: Any] else { return }
            var messages: [MessageItem] = []
            dict.forEach { key, value in
                let messageDict = value as? [String: Any] ?? [:]
                var message = MessageItem(id: key, isGroupChat: channel.isGroupChat, dictionary: messageDict)
                let messageSender = channel.members.first(where: { $0.uid == message.ownerUid })
                message.sender = messageSender
                messages.append(message)
                if messages.count == snapshot.childrenCount{
                    messages.sort { $0.timestamp < $1.timestamp}
                    completion(messages)
                }
                
            }
        } withCancel: { error in
            print("Failed to retrive messages for \(channel.title)")
        }
    }
    
    static func getHistoricalMessages(
        for channel: ChannelItem,
        lastCursor: String?,
        pageSize: UInt,
        completion: @escaping (MessageNode) -> Void
    ) {
        var messageQuery: DatabaseQuery
        if lastCursor == nil {
            messageQuery = FirebaseConstants.MessagesRef.child(channel.id).queryLimited(toLast: pageSize)
        } else {
            messageQuery = FirebaseConstants.MessagesRef.child(channel.id)
                .queryOrderedByKey()
                .queryEnding(atValue: lastCursor)
                .queryLimited(toLast: pageSize + 1)
        }
        
        messageQuery.observeSingleEvent(of: .value) { mainSnapshot in
            guard mainSnapshot.exists(),
                  let allObjects = mainSnapshot.children.allObjects as? [DataSnapshot] else {
                completion(.emptyMessageNode)
                return
            }
            
            var messages: [MessageItem] = allObjects.compactMap { messageSnapshot in
                let messageDict = messageSnapshot.value as? [String: Any] ?? [:]
                var message = MessageItem(id: messageSnapshot.key, isGroupChat: channel.isGroupChat, dictionary: messageDict)
                let messageSender = channel.members.first { $0.uid == message.ownerUid }
                message.sender = messageSender
                return message
            }
            
            messages.sort { $0.timestamp < $1.timestamp }
            
            if messages.count == mainSnapshot.childrenCount {
                let filterdMessages = lastCursor == nil ? messages : messages.filter { $0.id != lastCursor }
                let currentCursor = messages.first?.id
                let messageNode = MessageNode(messages: filterdMessages, currentCursor: currentCursor)
                completion(messageNode)
            } else {
                completion(.emptyMessageNode)
            }
            
        } withCancel: { error in
            print("Failed to retrieve messages for \(channel.title): \(error.localizedDescription)")
            completion(.emptyMessageNode)
        }
    }
    
    
    //    static func gitFirstMessage(for channel: ChannelItem, completion: @escaping (MessageItem)-> Void) {
    //        let query = FirebaseConstants.MessagesRef.child(channel.id).queryLimited(toFirst: 1)
    //        query.observeSingleEvent(of: .value) { snapshot in
    //            guard let dictionary = snapshot.value as? [String: Any] else { return }
    //            dictionary.forEach { key, value in
    //                let messageDict = value as? [String: Any] ?? [:]
    //                var firstMessage = MessageItem(id: key, isGroupChat: channel.isGroupChat, dictionary: messageDict)
    //                let messageSender = channel.members.first { $0.uid == firstMessage.ownerUid }
    //                firstMessage.sender = messageSender
    //                completion(firstMessage)
    //            }
    //        } withCancel: { error in
    //            print("Failed to retrieve messages for \(channel.title): \(error.localizedDescription)")
    //        }
    //    }
    
    static func getFirstMessage(for channel: ChannelItem, completion: @escaping (MessageItem?) -> Void) {
        let query = FirebaseConstants.MessagesRef.child(channel.id).queryLimited(toFirst: 1)
        query.observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else {
                print("No messages found for channel \(channel.title)")
                completion(nil)
                return
            }
            
            for (key, value) in dictionary {
                if let messageDict = value as? [String: Any] {
                    var firstMessage = MessageItem(id: key, isGroupChat: channel.isGroupChat, dictionary: messageDict)
                    if let messageSender = channel.members.first(where: { $0.uid == firstMessage.ownerUid }) {
                        firstMessage.sender = messageSender
                        completion(firstMessage)
                        return // Exit after finding the first message
                    } else {
                        print("Sender not found for message in channel \(channel.title)")
                        completion(nil)
                        return
                    }
                } else {
                    print("Invalid message format in channel \(channel.title)")
                    completion(nil)
                    return
                }
            }
        } withCancel: { error in
            print("Failed to retrieve messages for \(channel.title): \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    static func listenForNewMessage(for channel: ChannelItem, completion: @escaping (MessageItem?) -> Void) {
        FirebaseConstants.MessagesRef.child(channel.id)
            .queryLimited(toLast: 1)
            .observe(.childAdded) { snapshot in
            guard let messageDict = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }
            
            let messageId = snapshot.key
            var newMessage = MessageItem(id: messageId, isGroupChat: channel.isGroupChat, dictionary: messageDict)
            let messageSender = channel.members.first { $0.uid == newMessage.ownerUid }
            newMessage.sender = messageSender
            completion(newMessage)
        } withCancel: { error in
            print("Failed to listen for new messages for \(channel.title): \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    
}

/// Represents a node in the user pagination, containing a list of users and a cursor.
struct MessageNode {
    var messages: [MessageItem]
    var currentCursor: String? // The key of the last user retrieved in the current page.
    
    /// An empty UserNode instance for representing an empty state.
    static let emptyMessageNode = MessageNode(messages: [], currentCursor: nil)
}


struct MessageUploadParams {
    let channel : ChannelItem
    let text : String
    let type: MessageType
    let attachment: MediaAttachment
    var thumbnailUrl: String?
    var videoUrl: String?
    var audioURL: String?
    var audioDuration: TimeInterval?
    var sender: UserItem
    
    var ownerUID: String {
        return sender.uid
    }
    
    var thumbnailWidth: CGFloat? {
        guard type == .photo || type == .photo else { return nil }
        return attachment.thumbnail.size.width
    }
    
    var thumbnailHeight: CGFloat? {
        guard type == .photo || type == .photo else { return nil }
        return attachment.thumbnail.size.height
    }
    
    
}
