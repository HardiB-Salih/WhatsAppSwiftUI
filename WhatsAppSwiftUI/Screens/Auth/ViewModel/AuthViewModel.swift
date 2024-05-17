//
//  AuthViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import Foundation

class AuthViewModel: ObservableObject {
    // MARK: -Published Properties
    @Published var isLoading: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    
    
    // MARK: -Computed Properties
    var disableLoginButton: Bool {
        return email.isEmpty || password.isEmpty || password.count < 6 || isLoading
    }
    
    var disableSignupButton: Bool {
        return email.isEmpty || username.isEmpty || password.isEmpty || password.count < 6 || isLoading
    }
    
}
