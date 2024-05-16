//
//  TextInputArea.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct TextInputArea: View {
    @State private var text = ""
    var body: some View {
        HStack (alignment: .bottom) {
            HStack (alignment: .bottom, spacing: 0){
                TextField("Message", text: $text, axis: .vertical)
                    .padding(10)
                    
                
                Button("", systemImage: "photo.on.rectangle.angled", action: {})
                    .padding(12)
                    .tint(.black)
                    

            }
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .stroke(Color(.systemGray4) ,lineWidth: 1.0)
            }
            
            AudioOrTextButton(text: $text)
        }
    }
}


private struct AudioOrTextButton: View {
    @Binding var text: String
    var body: some View {
        Button(action: {
            text = ""
        }, label: {
            Image(systemName: text.isEmpty ? "mic.fill" : "paperplane.fill")
                .foregroundStyle(.black)
                .padding(12)
                .background(Color(.systemGreen))
                .clipShape(Circle())
        })
    }
}

#Preview {
    TextInputArea()
}
