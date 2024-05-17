//
//  AuthTextFeild.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct AuthTextFeild: View {
    @Binding var text : String
    let inputType: InputType

    var body: some View {
        HStack {
            Image(systemName: inputType.iconName)
                .font(.body)

            switch inputType {
            case .password:
                SecureField(inputType.placeholder, text: $text).fontWeight(.semibold)
            default:
                TextField(inputType.placeholder, text: $text).fontWeight(.semibold)
            }
            
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(.systemGray5), lineWidth: 1.0))
    }
}

extension AuthTextFeild {
    enum InputType {
        case email
        case password
        case custom(_ placeholder: String, _ iconName: String)
        
        var placeholder: String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .custom(let placeholder, _ ):
                return placeholder
            }
        }
        
        var iconName: String {
            switch self {
            case .email:
                return "envelope"
            case .password:
                return "lock"
            case .custom(_, let iconName ):
                return iconName
            }
        }
        
        var keybordType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            default:
                return .default
            }
        }
    }
}

#Preview {
    AuthTextFeild(text: .constant(""), inputType: .password)
}
