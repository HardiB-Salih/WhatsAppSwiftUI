//
//  MessageListController.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class MessageListController: UIViewController {
    
    //MARK: -View Life Sycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpMessageLisners()
    }
    
    init(_ viewModel: ChatRoomViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        subscription.forEach { $0.cancel() }
        subscription.removeAll()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -Properties
    private let viewModel: ChatRoomViewModel
    private var subscription = Set<AnyCancellable>()
    private let cellIdentifier = "MessageListControllerCells"
    // Lazy property for tableView with an anonymous closure
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .clear
        return tableView
    }()

    
    //MARK: -Methods
    private func setUpViews() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        ])
    }
    
    private func setUpMessageLisners() {
        let delay = 200
        viewModel.$messages
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink {[weak self] _ in
            self?.tableView.reloadData()
            }.store(in: &subscription)
    }
    
}

// MARK: -UITableViewDelegate & UITableViewDataSource
extension MessageListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let message = viewModel.messages[indexPath.row]
        
        cell.contentConfiguration = UIHostingConfiguration {
            switch message.type {
            case .text:
                BubbleTextView(item: message)
            case .photo, .video:
                BubblePhotoView(item: message)
            case .audio:
                BubbleAudioView(item: message)
            case .admin(let adminType):
                switch adminType {
                case .channelCreation:
                    ChannelCreationTextView()
                    if viewModel.channel.isGroupChat {
                        AdminMessageTextView(channel: viewModel.channel)
                    }
                default :
                    Text("Unknown")
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

#Preview {
    MessageListView(viewModel: ChatRoomViewModel(channel: .placeholder))
}

