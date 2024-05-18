//
//  SelectedChatPartnerView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/18/24.
//

import SwiftUI

struct SelectedChatPartnerView: View {
    let users: [UserItem]
    let onTap: (_ user: UserItem) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(users) { user in
                    selectedChatPartner(user: user)
                }
            }
            
        }
    }
    
    private func selectedChatPartner(user: UserItem) -> some View {
        VStack(alignment: .center) {
            Circle().frame(width: 60, height: 60)
                .overlay (alignment: .topTrailing){
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .foregroundStyle(.black)
                        .padding(5)
                        .background(.thinMaterial)
                        .clipShape(Circle())
                        .onTapGesture {
                            onTap(user)
                        }
                }
            Text(user.username)
                .font(.footnote)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    SelectedChatPartnerView(users: UserItem.placeholders) { _ in }
}
