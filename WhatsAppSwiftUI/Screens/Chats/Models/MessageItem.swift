//
//  MessageItem.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import Foundation
import SwiftUI
import Firebase

struct MessageItem: Identifiable {
    typealias userId = String
    typealias emoji = String
    typealias emojiCount = Int

    
    let id : String
    let isGroupChat: Bool
    let text: String
    let type: MessageType
    let ownerUid: String
    let timestamp: Date
    var direction: MessageDirection {
        guard let currentUid = Auth.auth().currentUser?.uid else { return .received}
        return ownerUid == currentUid ? .sent : .received
    }
    var sender: UserItem?
    
    var thumbnailUrl: String?
    var thumbnailWidth: CGFloat?
    var thumbnailHeight: CGFloat?
    var videoURL: String?
    
    var audioURL: String?
    var audioDuration: TimeInterval?
    var reactions: [emoji: emojiCount] = [:]
    var userReaction: [userId: emoji] = [:]
    
    private let horizantalPadding:CGFloat = 25
    
}



// MARK: Computed Propurty
extension MessageItem {
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    var alignment: Alignment {
        return direction == .received ? .leading : .trailing
    }
    
    var horizontalAlignment: HorizontalAlignment {
        return direction == .received ? .leading : .trailing
    }
    
    
    var showGroupPartnerInfo: Bool {
        return isGroupChat && direction == .received
    }
    
    var leadingPadding: CGFloat {
        return direction == .received ? 0 : horizantalPadding
    }
    
    var traillingPadding: CGFloat {
        return direction == .received ? horizantalPadding : 0
    }
    
    var thumbnailURL: URL? {
        return URL(string: thumbnailUrl ?? "")
    }
    
    
    //MARK: Set The Image Size Dinamicly
    var imageSize: CGSize {
        let photoWidth = thumbnailWidth ?? 0
        let photoHeight = thumbnailHeight ?? 0
        let imageHeight = CGFloat(photoHeight / photoWidth * imageWith)
        return CGSize(width: imageWith, height: imageHeight)
    }
    
    var imageWith: CGFloat {
        ///UIScreen.width / 1,5
        let photoWidth = (UIWindowScene.current?.screenWidth ?? 0) / 1.5
        return photoWidth
    }
    
    
    var audioDurationInString: String {
        return audioDuration?.formatElapsedTime ?? "00:00"
    }
    
    var isSendByMe: Bool {
        return ownerUid == Auth.auth().currentUser?.uid ?? ""
    }
     
    func containsSameOwner(as message: MessageItem) -> Bool {
        if let userA = message.sender, let userB = self.sender {
            return userA == userB
        } else {
            return false
        }
    }
    
    
    var menuAnchor: UnitPoint {
        return direction == .received ? .leading : .trailing
    }
    
    var reactionAnchor: Alignment {
        return direction == .sent ? .bottomTrailing : .bottomLeading
    }
    
    var hasReaction : Bool {
        return !reactions.isEmpty
    }
}

// MARK: ENUMS
enum MessageDirection {
    case sent, received
    
    static var random: MessageDirection {
        return [MessageDirection.sent, .received].randomElement() ?? .sent
    }
}


// MARK: Placeholder
extension MessageItem {
    static let sentPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: false,
                                             text: "Holly Molly",
                                             type: .text,
                                             ownerUid: "1", timestamp: Date())
    
    static let receivedPlaceholder = MessageItem(id: UUID().uuidString, isGroupChat: true,
                                                 text: "How are you Dude How is everything going on with you.",
                                                 type: .text,
                                                 ownerUid: "2", timestamp: Date())
    
    static let stubMessages: [MessageItem] = [
        MessageItem(id: UUID().uuidString, isGroupChat: true, text: "Text Message", type: .text, ownerUid: "3", timestamp: Date()),
        MessageItem(id: UUID().uuidString, isGroupChat: false,text: "Check out this photo", type: .photo, ownerUid: "4", timestamp: Date()),
        MessageItem(id: UUID().uuidString, isGroupChat: true,text: "Check out this video", type: .video, ownerUid: "5", timestamp: Date()),
        MessageItem(id: UUID().uuidString, isGroupChat: false,text: "Check out this video", type: .audio, ownerUid: "6", timestamp: Date())
    ]
}

extension MessageItem {
    init(id: String, isGroupChat: Bool , dictionary: [String: Any]) {
        self.id = id
        self.isGroupChat = isGroupChat
        self.text = dictionary[.text] as? String ?? ""
        let type = dictionary[.type] as? String ?? ""
        self.type = MessageType(type) ?? .text
        self.ownerUid = dictionary[.ownerUid] as? String ?? ""
        let timeInterval = dictionary[.timestamp] as? TimeInterval ?? 0
        self.timestamp = Date(timeIntervalSince1970: timeInterval)
        self.thumbnailUrl = dictionary[.thumbnailUrl] as? String ?? nil
        self.thumbnailWidth = dictionary[.thumbnailWidth] as? CGFloat ?? nil
        self.thumbnailHeight = dictionary[.thumbnailHeight] as? CGFloat ?? nil
        self.videoURL = dictionary[.videoURL] as? String ?? nil
        self.audioURL = dictionary[.audioURL] as? String ?? nil
        self.audioDuration = dictionary[.audioDuration] as? TimeInterval ?? nil
        self.reactions = dictionary[.reactions] as? [emoji: emojiCount] ?? [:]
        self.userReaction = dictionary[.userReaction] as? [userId: emoji] ?? [:]


    }
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownderUid"
    static let thumbnailUrl = "thumbnailUrl"
    static let thumbnailWidth = "thumbnailWidth"
    static let thumbnailHeight = "thumbnailHeight"
    static let videoURL = "videoURL"
    static let audioURL = "audioURL"
    static let audioDuration = "audioDuration"
    static let reactions = "reactions"
    static let userReaction = "userReaction"
}
