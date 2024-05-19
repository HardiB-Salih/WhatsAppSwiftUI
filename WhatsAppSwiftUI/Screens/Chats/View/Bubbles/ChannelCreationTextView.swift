//
//  ChannelCreationTextView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import SwiftUI

struct ChannelCreationTextView: View {

    @Environment(\.colorScheme) private var colorScheme
    var backgroundColor: Color  {
        return colorScheme == .dark ? Color.black : Color.yellow
    }
    
    var body: some View {
        ZStack (alignment: .top){
            (
                Text(Image(systemName: "lock.fill"))
                +
                Text("Message and calls are end-to-end encrypted, No one outside of this chat, not even whatsApp, can read or listen to them.")
                +
                Text(" Learn more.")
                    .bold()
            )
        }
        .font(.footnote)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(backgroundColor.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }
}

#Preview {
    ChannelCreationTextView()
}
