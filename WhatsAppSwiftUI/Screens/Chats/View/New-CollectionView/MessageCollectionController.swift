//
//  MessageCollectionController.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 7/3/24.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class MessageCollectionController: UIViewController {
    
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
    private let cellIdentifier = "MessageCollectionControllerCells"
    
    private lazy var pullToRefresh: UIRefreshControl = {
        let pullToRefresh = UIRefreshControl()
        pullToRefresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return pullToRefresh
    }()
    
    private let compositionalLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = UIColor.gray.withAlphaComponent(0.0001)
        listConfig.showsSeparators = false
        let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
        section.contentInsets.leading = 0
        section.contentInsets.trailing = 0
        ///this is the spacing between two row
        section.interGroupSpacing = -8
        return section
    }
    // Lazy property for tableView with an anonymous closure
    private lazy var messagesCollcetionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .onDrag
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        //        collectionView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        //        collectionView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        collectionView.refreshControl = pullToRefresh
        return collectionView
    }()
    
    
    //MARK: -Methods
    private func setUpViews() {
        view.addSubview(messagesCollcetionView)
        
        NSLayoutConstraint.activate([
            messagesCollcetionView.topAnchor.constraint(equalTo: view.topAnchor),
            messagesCollcetionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesCollcetionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollcetionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpMessageLisners() {
        let delay = 200
        viewModel.$messages
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.messagesCollcetionView.reloadData()
            }.store(in: &subscription)
        
        viewModel.$scrollToBottomRequest
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink {[weak self] scrollRequest in
                if scrollRequest.scroll {
                    self?.messagesCollcetionView.scrollToLastItem(at: .bottom, animated: scrollRequest.animated)
                    
                }
                
            }.store(in: &subscription)
    }
    
    @objc private func refreshData() {
        messagesCollcetionView.refreshControl?.endRefreshing()
    }
    
}

// MARK: -UITableViewDelegate & UITableViewDataSource
extension MessageCollectionController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = messagesCollcetionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        let message = viewModel.messages[indexPath.item]
        cell.contentConfiguration = UIHostingConfiguration {
            BubbleView(message: message,
                       channel: viewModel.channel,
                       isNewDay: viewModel.isNewDay(for: message, at: indexPath.item),
                       showSenderName: viewModel.showSenderName(for: message, at: indexPath.item)
            )
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
