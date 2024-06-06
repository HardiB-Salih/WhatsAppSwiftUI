//
//  TextInputArea.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct TextInputArea: View {
    @State private var isPulsing = false

    @Binding var textMessage: String
    @Binding var isRecording : Bool
    @Binding var elapsedTime : TimeInterval
    let actionHandler: (_ action: UserAction) -> Void

    
    var body: some View {
        HStack (alignment: .bottom) {
            Group {
                if isRecording {
                    audioSessionIndicatorView()
                } else {
                    messageTextField()
                }
            }
            .transition(.blurReplace)
            .frame(height: 44)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                    .stroke(Color(.systemGray4) ,lineWidth: 1.0)
            }
           
            audioOrTextButton()
        }
        .onChange(of: isRecording, { oldValue, isRecording in
            if isRecording {
                withAnimation(.easeIn(duration: 1.5).repeatForever()) {
                    isPulsing = true
                }
            } else { isPulsing = false }
        })
        .animation(.easeInOut, value: isRecording)
    }
    
    //MARK: - audioSessionIndicatorView
    private func audioSessionIndicatorView() -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundStyle(.red)
                .font(.caption)
                .scaleEffect(isPulsing ? 1.8 : 1.0)
            
            Text("Recording Audio")
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            
            Text(elapsedTime.formatElapsedTime)
                .font(.callout)
                .lineLimit(1)
            
        }
        .padding(11)
        
    }
    
    //MARK: - messageTextField
    private func messageTextField() -> some View {
        HStack (alignment: .bottom, spacing: 0){
            TextField("Message", text: $textMessage, axis: .vertical)
                .padding(10)
                .keyboardType(.default)
            
            photoPickerButton()

        }
    }
    
    
    //MARK: - photoPickerButton
    private func photoPickerButton() -> some View {
        Button(action: {
            actionHandler(.presentPhotoPicker)
        }, label: {
            Image(systemName:  "photo.on.rectangle.angled")
                .padding(12)
                .tint(.black)
        })
    }
    
    //MARK: - audioOrTextButton
    private func audioOrTextButton() -> some View {
        Button(action: {
            if textMessage.isEmptyOrWhitespaces {
                actionHandler(.recordAudio)
            } else {
                actionHandler(.sendMessage)
            }
        }, label: {
            Image(systemName: textMessage.isEmptyOrWhitespaces ? isRecording ? "square.fill": "mic.fill" : "paperplane.fill")
                .foregroundStyle(.white)
                .padding(12)
                .background(Color(isRecording ? .systemRed : .systemGreen))
                .clipShape(Circle())
                .frame(height: 44)
        })
        .animation(.easeInOut, value: isRecording)
    }
}

//MARK: - UserAction
extension TextInputArea {
    enum UserAction {
        case presentPhotoPicker
        case sendMessage
        case recordAudio
    }
}

#Preview {
    TextInputArea(textMessage: .constant(""), isRecording: .constant(false), elapsedTime: .constant(0)) { action in
        switch action {
        case .presentPhotoPicker:
            break
        case .sendMessage:
            break
        case .recordAudio:
            break
        }
    }
}
