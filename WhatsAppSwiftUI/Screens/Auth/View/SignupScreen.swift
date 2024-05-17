//
//  SignupScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct SignupScreen: View {
    @ObservedObject var authVM : AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            AuthHeaderView()
            
            AuthTextFeild(text: $authVM.email, inputType: .email)
            
            AuthTextFeild(text: $authVM.username, inputType: .custom("Username", "at"))
            
            AuthTextFeild(text: $authVM.password, inputType: .password)
            
            AuthButton(title: "Create account") {
                Task { try await authVM.handleSignUp() }
            }
            .disabled(authVM.disableSignupButton)
            .padding(.vertical)
            
            Spacer()
            
            Divider()
            backButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.9), Color.green.opacity(0.7), Color.teal.opacity(0.8)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .navigationBarBackButtonHidden()
        
        
    }
    
    private func backButton() -> some View {
        Button { dismiss()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                (
                    Text("Already have an account ? ")
                    +
                    Text("Sign in")
                        .fontWeight(.bold)
                )
                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    SignupScreen(authVM: AuthViewModel())
}
