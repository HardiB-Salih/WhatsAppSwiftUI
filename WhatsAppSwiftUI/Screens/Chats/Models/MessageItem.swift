//
//  MessageItem.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import Foundation
import SwiftUI

struct MessageItem: Identifiable {
    
    let id : String = UUID().uuidString
    let text: String
    let type: MessageType
    let direction: MessageDirection
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

enum MessageType {
    case text, photo, video, audio
}

// MARK: Placeholder
extension MessageItem {
    static let sentPlaceholder = MessageItem(text: "Holly Molly", 
                                             type: .text,
                                             direction: .sent)
    
    static let receivedPlaceholder = MessageItem(text: "How are you Dude How is everything going on with you.",
                                                 type: .text,
                                                 direction: .received)
    
    static let stubMessages: [MessageItem] = [
        MessageItem(text: "Text Message", type: .text, direction: .sent),
        MessageItem(text: "Check out this photo", type: .photo, direction: .received),
        MessageItem(text: "Check out this video", type: .video, direction: .sent),
        MessageItem(text: "Check out this video", type: .audio, direction: .received)


    ]
}
