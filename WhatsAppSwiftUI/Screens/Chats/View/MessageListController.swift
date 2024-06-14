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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.backgroundColor = .clear
//        tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
//        tableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    
    //MARK: -Methods
    private func setUpViews() {
        view.addSubview(tableView)

        
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
        
        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink {[weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.tableView.scrollToLastRow(at: .bottom, animated: scrollRequest.animated)
                }
                
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.dismissKeyboard()
        let messageItem = viewModel.messages[indexPath.row]
        
        switch messageItem.type {
        case .video:
            guard let videoURLString = messageItem.videoURL,
                  let videoURL = URL(string: videoURLString)
            else { return }
            viewModel.showMediaPlayer(videoURL)
        default:
            break
        }
    }
    
}

//#Preview {
//    MessageListView(viewModel: ChatRoomViewModel(channel: .placeholder))
//}


private extension UITableView {
    /// Scrolls to the last row of the table view.
    ///
    ///Example
    ///```swift
    /// let tableView: UITableView = ...
    /// // Scroll to the last row in the table view
    /// tableView.scrollToLastRow(at: .bottom, animated: true)
    /// ```
    /// - Parameters:
    ///   - scrollPosition: The scroll position to use.
    ///   - animated: Specify `true` to animate the scrolling behavior or `false` to adjust the scroll position immediately.
    func scrollToLastRow(at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard numberOfRows(inSection: numberOfSections - 1) > 0 else { return }
        
        let lastSectionIndex = numberOfSections - 1
        let lastRowIndex = numberOfRows(inSection: lastSectionIndex) - 1
        let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        scrollToRow(at: lastRowIndexPath, at: scrollPosition, animated: animated)
    }
}



private extension UICollectionView {
    ///  Scrolls to the last item of the collection view.
    ///
    /// Example
    ///  ```swift
    ///   let collectionView: UICollectionView = ...
    ///   // Scroll to the last item in the collection view
    ///   collectionView.scrollToLastItem(at: .bottom, animated: true)
    ///  ```
    ///
    ///  - Parameters:
    ///    - scrollPosition: The scroll position to use.
    ///    - animated: Specify `true` to animate the scrolling behavior or `false` to adjust the scroll position immediately.
    func scrollToLastItem(at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard numberOfSections > 0 else { return }
        
        let lastSectionIndex = numberOfSections - 1
        let lastItemIndex = numberOfItems(inSection: lastSectionIndex) - 1
        
        guard lastItemIndex >= 0 else { return }
        
        let lastItemIndexPath = IndexPath(item: lastItemIndex, section: lastSectionIndex)
        scrollToItem(at: lastItemIndexPath, at: scrollPosition, animated: animated)
    }
}
