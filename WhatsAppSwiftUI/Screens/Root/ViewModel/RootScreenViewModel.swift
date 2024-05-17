//
//  RootScreenViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import Foundation
import Combine

final class RootScreenViewModel : ObservableObject {
    @Published private(set) var authState: AuthState = AuthState.pending
    private var cancellable : AnyCancellable?
    
    init() {
        listenForAuthState()
    }
    
    func listenForAuthState() {
        cancellable = AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] latestAuthState in
            self?.authState = latestAuthState
        }
    }
}
