//
//  ChatPartnerRowView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct ChatPartnerRowView<Content: View>: View {
    private let user: UserItem
    private let trailingItem : Content
    
    init(user: UserItem, @ViewBuilder trailingItem: () -> Content = { EmptyView() }) {
        self.user = user
        self.trailingItem = trailingItem()
    }
    
    var body: some View {
        HStack{
            Circle()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(user.username)
                    .fontWeight(.bold)
                    .foregroundStyle(.whatsAppBlack)
                
                Text(user.bioUnweappede)
                    .font(.caption)
                    .foregroundStyle(Color(.systemGray))
            }
            Spacer()
            
            trailingItem
        }
    }
}

#Preview {
    ChatPartnerRowView(user: .placeholder)
}
