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
    
    let id : String
    let text: String
    let type: MessageType
    let ownerUid: String
    let timestamp: Date
    var direction: MessageDirection {
        guard let currentUid = Auth.auth().currentUser?.uid else { return .received}
        return ownerUid == currentUid ? .sent : .received
    }
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
    static let sentPlaceholder = MessageItem(id: UUID().uuidString,
                                             text: "Holly Molly",
                                             type: .text,
                                             ownerUid: "1", timestamp: Date())
    static let receivedPlaceholder = MessageItem(id: UUID().uuidString,
                                                 text: "How are you Dude How is everything going on with you.",
                                                 type: .text,
                                                 ownerUid: "2", timestamp: Date())
    
    static let stubMessages: [MessageItem] = [
        MessageItem(id: UUID().uuidString, text: "Text Message", type: .text, ownerUid: "3", timestamp: Date()),
        MessageItem(id: UUID().uuidString,text: "Check out this photo", type: .photo, ownerUid: "4", timestamp: Date()),
        MessageItem(id: UUID().uuidString,text: "Check out this video", type: .video, ownerUid: "5", timestamp: Date()),
        MessageItem(id: UUID().uuidString,text: "Check out this video", type: .audio, ownerUid: "6", timestamp: Date())
    ]
}

extension MessageItem {
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.text = dictionary[.text] as? String ?? ""
        
        let type = dictionary[.type] as? String ?? ""
        self.type = MessageType(type) ?? .text
        self.ownerUid = dictionary[.ownerUid] as? String ?? ""
        let timeInterval = dictionary[.timestamp] as? TimeInterval ?? 0
        self.timestamp = Date(timeIntervalSince1970: timeInterval)
    }
}

extension String {
    static let text = "text"
    static let `type` = "type"
    static let timestamp = "timestamp"
    static let ownerUid = "ownderUid"
}
