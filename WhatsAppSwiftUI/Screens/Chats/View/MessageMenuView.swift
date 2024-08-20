//
//  MessageMenuView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 8/21/24.
//

import SwiftUI

struct MessageMenuView: View {
    let message: MessageItem
    @State private var animateBackgroundView: Bool = false

    var body: some View {
        VStack (alignment: .leading, spacing: 1){
            ForEach(MessageMenuAction.allCases) { action in
                buttonBody(action)
                    .frame(height: 45)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(action == .delete ? .red : .whatsAppBlack)
                if action != .delete {
                    Divider()
                }
            }
        }
        .frame(width: message.imageWith)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .scaleEffect(animateBackgroundView ? 1 : 0, anchor: message.menuAnchor) 
        .opacity(animateBackgroundView ? 1 : 0)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 0)
        .onAppear{
            withAnimation(.easeIn(duration: 0.2)) {
                animateBackgroundView = true
            }
        }
    }
    
    private func buttonBody(_ action: MessageMenuAction) -> some View {
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
            HStack {
                Text(action.rawValue.capitalized)
                Spacer()
                Image(systemName: action.systemImage)
            }
            .padding()
        })
    }
}

#Preview {
    ZStack{
        Rectangle().fill(.whatsAppGray)
        MessageMenuView(message: .receivedPlaceholder)
    }
}
