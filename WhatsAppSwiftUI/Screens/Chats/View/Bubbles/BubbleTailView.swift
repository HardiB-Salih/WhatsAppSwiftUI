//
//  BubbleTailView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct BubbleTailView: View {
    var direction: MessageDirection
    
    private var tintColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    var body: some View {
        Image(direction == .sent ? .outgoingTail : .incomingTail)
            .renderingMode(.template)
            .resizable()
            .frame(width: 13, height: 13)
            .offset(y: 4)
            .foregroundStyle(tintColor)
    }
}

#Preview {
    BubbleTailView(direction: .sent)
}
