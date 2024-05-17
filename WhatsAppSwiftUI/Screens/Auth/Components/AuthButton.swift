//
//  AuthButton.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct AuthButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    
    var backgroundColor : Color {
        return isEnabled ? Color.white : Color.white.opacity(0.3)
    }
    var textColor : Color {
        return isEnabled ? Color.green : Color.white
    }
    
    var body: some View {
        Button(action: action, label: {
            HStack {
                Text(title)
                Image(systemName: "arrow.right")
            }
            .font(.headline)
            .foregroundStyle(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        })
    }
}

#Preview {
    ZStack {
        Color.teal
        AuthButton(title: "Login", action: {})
    }
}
