//
//  MessageCollectionView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 7/3/24.
//

import SwiftUI

struct MessageCollectionView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MessageCollectionController
    private var viewModel: ChatRoomViewModel
    
    init(viewModel: ChatRoomViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> MessageCollectionController {
        let messageCollectionController = MessageCollectionController(viewModel)
        return messageCollectionController
    }
    
    func updateUIViewController(_ uiViewController: MessageCollectionController,
                                context: Context) { }
}

#Preview {
    MessageCollectionView(viewModel: ChatRoomViewModel(channel: .placeholder))
}

