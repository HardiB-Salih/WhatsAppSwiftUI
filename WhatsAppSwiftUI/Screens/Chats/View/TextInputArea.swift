//
//  TextInputArea.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct TextInputArea: View {
    @Binding var textMessage: String
    let actionHandler: (_ action: UserAction) -> Void
    
    var body: some View {
        HStack (alignment: .bottom) {
            HStack (alignment: .bottom, spacing: 0){
                TextField("Message", text: $textMessage, axis: .vertical)
                    .padding(10)
                    .keyboardType(.default)
                
                
                Button(action: {
                    actionHandler(.presentPhotoPicker)
                }, label: {
                    Image(systemName:  "photo.on.rectangle.angled")
                        .padding(12)
                        .tint(.black)
                })
                
                
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .stroke(Color(.systemGray4) ,lineWidth: 1.0)
            }
            
            audioOrTextButton()
        }
    }
    
    
    private func audioOrTextButton() -> some View {
        Button(action: {
            textMessage.isEmptyOrWhitespaces ? actionHandler(.sendAudio) : actionHandler(.sendMessage)
        }, label: {
            Image(systemName: textMessage.isEmptyOrWhitespaces ? "mic.fill" : "paperplane.fill")
                .foregroundStyle(.black)
                .padding(12)
                .background(Color(.systemGreen))
                .clipShape(Circle())
        })
    }
}

extension TextInputArea {
    enum UserAction {
        case presentPhotoPicker
        case sendMessage
        case sendAudio
    }
}

#Preview {
    TextInputArea(textMessage: .constant("")) { a in }
}
