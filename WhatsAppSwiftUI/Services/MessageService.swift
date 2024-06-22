//
//  MessageService.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import Foundation
import FirebaseDatabase

struct MessageService {
    
    static func sendTextMessage(to channel: ChannelItem, from currentUser: UserItem, _ textMessge: String, onComplete: () -> Void) {
        let timestamp = Date().timeIntervalSince1970
        guard let messageId = FirebaseConstants.MessagesRef.childByAutoId().key else { return }
        
        let chaneelDictionary: [String: Any] = [
            .lastMessage: textMessge,
            .lastMessageTimestamp: timestamp
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
                let message = MessageItem(id: key, isGroupChat: channel.isGroupChat, dictionary: messageDict)
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
