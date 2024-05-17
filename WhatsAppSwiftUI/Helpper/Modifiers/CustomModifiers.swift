//
//  CustomModifiers.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

//MARK: -BubbleTailModifiers
private struct BubbleTailModifiers: ViewModifier {
    var direction: MessageDirection
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: direction == .received ? .bottomLeading : .bottomTrailing) {
                BubbleTailView(direction: direction)
            }
    }
}

extension View {
    func applyTail(_ direction: MessageDirection) -> some View {
        self.modifier(BubbleTailModifiers(direction: direction))
    }
}
