//
//  SettingItemView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct SettingItemView: View {
    let item: SettingsItem
    
    var body: some View {
        HStack {
            iconImageView()
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(item.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            Text(item.title).fontWeight(.semibold)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func iconImageView() -> some View {
        switch item.imageType {
        case .systemImage:
            Image(systemName: item.imageName)
                .bold()
                .font(.callout)
        case .assetImage:
            Image(item.imageName)
                .renderingMode(.template)
                .padding(3)
        }
            
    }
}

#Preview {
    SettingItemView(item: .chats)
}
