//
//  ChannelItemView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct ChannelItemView: View {
    let messageType : MessageType
    
    var body: some View {
        HStack (alignment: .top){
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .padding()
                .background(Color(.gray))
                .clipShape(Circle())
            
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Qauser12")
                    .fontWeight(.bold)
                
                    
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: messageType.icon)
                    Text(messageType.title)
                }.foregroundStyle(Color(.systemGray2))
            }
            
            Spacer()
            
            Text("5:50 PM")
                .foregroundStyle(Color(.systemGray2))
        }
    }
}

extension ChannelItemView {
     enum MessageType : String {
        case voiceMessage, photoMessage
        
        
        fileprivate var title: String {
            switch self {
            case .voiceMessage:
                return "Voice Message"
            case .photoMessage:
                return "Photo Message"
            }
        }
        fileprivate var icon: String {
            switch self {
            case .voiceMessage:
                return "mic.fill"
            case .photoMessage:
                return "photo"
            }
        }
    }
}

#Preview {
    ChannelItemView(messageType: .voiceMessage)
}
