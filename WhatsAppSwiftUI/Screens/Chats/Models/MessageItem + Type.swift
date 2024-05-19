//
//  MessageItem + Type.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import Foundation
 
enum AdminMessageType : String {
    case channelCreation
    case memberAdded
    case memberLeft
    case channelNameChange
}

enum MessageType {
    case admin(_ type: AdminMessageType), text, photo, video, audio
    
    var title: String {
        switch self {
        case .admin:
            return "admin"
        case .text:
            return "text"
        case .photo:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "audio"
        }
    }
    
    // Convinan Init
    init?(_ stringValur: String) {
        switch stringValur {
        case "text":
            self = .text
        case "photo":
            self = .photo
        case "video":
            self = .video
        case "audio":
            self = .audio
        default:
            if let adminMessageType = AdminMessageType(rawValue: stringValur) {
                self = .admin(adminMessageType)
            } else {
                return nil
            }
        }
    }
}

extension MessageType: Equatable {
    static func ==(lhs: MessageType, rhs: MessageType) -> Bool {
        switch (lhs, rhs) {
        case (.admin(let leftAdmin), .admin(let rightAdmin)):
            return leftAdmin == rightAdmin
        case (.text, .text):
            return true
        case (.photo, .photo):
            return true
        case (.video, .video):
            return true
        case (.audio, .audio):
            return true
        default:
            return false
        }
    }
}
