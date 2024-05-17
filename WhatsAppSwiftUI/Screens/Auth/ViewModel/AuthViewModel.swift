//
//  AuthViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: -Published Properties
    @Published var isLoading: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Uh Oh")
    
    
    // MARK: -Computed Properties
    var disableLoginButton: Bool {
        return email.isEmpty || password.isEmpty || password.count < 6 || isLoading
    }
    
    var disableSignupButton: Bool {
        return email.isEmpty || username.isEmpty || password.isEmpty || password.count < 6 || isLoading
    }
    
    func handleSignUp() async throws {
        isLoading = true
        do {
            try await AuthManager.shared.createAccount(for: username, email: email, password: password)
        } catch {
            errorState.errorMessage = error.localizedDescription
            errorState.showError = true
            isLoading = false
        }
        
    }
    
}
