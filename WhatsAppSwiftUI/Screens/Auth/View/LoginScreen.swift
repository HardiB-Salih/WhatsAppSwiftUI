//
//  LoginScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import SwiftUI

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                AuthHeaderView()
                AuthTextFeild(text: $email, inputType: .email)
                AuthTextFeild(text: $password, inputType: .password)
                forgotPasswordButton()
                AuthButton(title: "Log in now", action: {})
                Spacer()
                
                Divider()
                signupButton()
                    .padding(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .ignoresSafeArea()
            .background(
                .teal.opacity(0.8).gradient
            )
        }
    }
    
    private func forgotPasswordButton() -> some View {
        NavigationLink {
            Text("Forgot PasswordPage")
        } label: {
            Text("Forgot Password?")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.vertical, 10)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
    
    private func signupButton() -> some View {
        NavigationLink {
            Text("Sign Up Page")
        } label: {
            HStack {
                Image(systemName: "sparkles")
                (
                Text("Dont Have an account ? ")
                +
                Text("Create one")
                    .fontWeight(.bold)
                )
                Image(systemName: "sparkles")
            }
            .foregroundStyle(.white)
            
        }

    }
}

#Preview {
    LoginScreen()
}
