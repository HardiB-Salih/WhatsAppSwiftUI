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
        setupLongPressGesterRecoganizer()
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
    private var lastScrollPostion: String?
    
    
    //MARK: Custom Reaction Properties
    private var startingFrame: CGRect?
    private var blurView: UIVisualEffectView?
    private var focusdView: UIView?
    private var highlightedCell : UICollectionViewCell?
    private var reactionHostVC: UIViewController?
    private var messageMenuVC: UIViewController?

//    private var snapshotCell: CGRect?

    
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
    
    private let pullDownHUDView: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        var imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .black)
        
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: imageConfig)
        buttonConfig.image = image
        buttonConfig.baseBackgroundColor = .bubbleGreen
        buttonConfig.baseForegroundColor = .whatsAppBlack
        buttonConfig.imagePadding = 5
        buttonConfig.cornerStyle = .capsule
        let font = UIFont.systemFont(ofSize: 12, weight: .black)
        buttonConfig.attributedTitle = AttributedString("Pull Down",
                                                        attributes: AttributeContainer([NSAttributedString.Key.font: font]))
        let button = UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()
    
    
    //MARK: -Methods
    private func setUpViews() {
        view.addSubview(messagesCollcetionView)
        view.addSubview(pullDownHUDView)
        
        NSLayoutConstraint.activate([
            messagesCollcetionView.topAnchor.constraint(equalTo: view.topAnchor),
            messagesCollcetionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesCollcetionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            messagesCollcetionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            pullDownHUDView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pullDownHUDView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        
        viewModel.$isPaginating
            .debounce(for: .milliseconds(delay), scheduler: DispatchQueue.main)
            .sink {[weak self] isPaginating in
                guard let self, let lastScrollPostion else { return }
                if isPaginating == false {
                    guard let index = viewModel.messages.firstIndex(where: { $0.id == lastScrollPostion }) else { return }
                    let indexPath = IndexPath(item: index, section: 0)
                    self.messagesCollcetionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    self.pullToRefresh.endRefreshing()
                }

            }.store(in: &subscription)
    }
    
    @objc private func refreshData() {

        lastScrollPostion = viewModel.messages.first?.id
        viewModel.paginateMoreMessage()
    }
    
}

// MARK: -UICollectionViewDelegate & UICollectionViewDataSource
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
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            pullDownHUDView.alpha = viewModel.isPaginatable ? 1 : 0
        } else {
            pullDownHUDView.alpha = 1
        }
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

extension CALayer {
    func applyShadow(color: UIColor, alpha: Float, x:CGFloat, y:CGFloat, blur: CGFloat) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = .init(width: x, height: y)
        shadowRadius = blur
        masksToBounds = false
    }
}

//MARK: Context menu interactions
extension MessageCollectionController {
    private func setupLongPressGesterRecoganizer(){
        let longPressGester = UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu))
        longPressGester.minimumPressDuration = 0.5
        messagesCollcetionView.addGestureRecognizer(longPressGester)
    }
    
    @objc private func showContextMenu(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: messagesCollcetionView)
        guard let indexPath = messagesCollcetionView.indexPathForItem(at: point) else { return }
        let message = viewModel.messages[indexPath.item]
        
        guard message.type.isAdminMessage == false else { return }
        
        guard let selectedCell = messagesCollcetionView.cellForItem(at: indexPath) else { return }
        highlightedCell = selectedCell
        highlightedCell?.alpha = 0
        startingFrame = selectedCell.superview?.convert(selectedCell.frame, to: nil)

        guard let snapshotCell = selectedCell.snapshotView(afterScreenUpdates: false) else { return }
        focusdView = UIView(frame: startingFrame ?? .zero)
        guard let focusdView else { return }
        focusdView.isUserInteractionEnabled = false
//        focusdView.backgroundColor = .yellow
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissContexMenu))
        let blurEffect = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: blurEffect)
        guard let blurView else { return }
        blurView.contentView.addGestureRecognizer(tapGesture)
        tapGesture.numberOfTapsRequired = 1
        blurView.contentView.isUserInteractionEnabled = true
        blurView.alpha = 0
        
        
        guard let keyWindow = UIWindowScene.current?.keyWindow else { return }
        keyWindow.addSubview(blurView)
        keyWindow.addSubview(focusdView)
        focusdView.addSubview(snapshotCell)
        blurView.frame = keyWindow.frame
        attachMenuActionItems(to: message, in: keyWindow, viewModel.isNewDay(for: message, at: indexPath.item))
        
        let shrikCell = shrinkCell(startingFrame?.height ?? 0)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) {
            blurView.alpha = 1
            focusdView.center.y = keyWindow.center.y - 60
            snapshotCell.frame = focusdView.bounds
            snapshotCell.layer.applyShadow(color: .gray, alpha: 0.2, x: 0, y: 2, blur: 4)
            
            if shrikCell {
                let Xtranslation: CGFloat = message.direction == .received ? -80 : 80
                let translation = CGAffineTransform(translationX: Xtranslation, y: 1)
                focusdView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(translation)
            }
        }
    }
    
    private func attachMenuActionItems(to message: MessageItem, in window: UIWindow, _ isNewData: Bool) {
        
        guard let focusdView, let startingFrame else { return }
        let shrikCell = shrinkCell(startingFrame.height)

        let reactionPickerView = ReactionPickerView(message: message) {[weak self] reaction in
            self?.dismissContexMenu()
            self?.viewModel.addReaction(reaction, to: message)
            print(reaction.emoji)
        }
        let reactionHostVC = UIHostingController(rootView: reactionPickerView)
        reactionHostVC.view.backgroundColor = .clear
        reactionHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(reactionHostVC.view)
        
        
        var reactionPadding: CGFloat = isNewData ? 45 : 5
        if shrikCell {
            reactionPadding += startingFrame.height / 3
        }
        reactionHostVC.view.bottomAnchor.constraint(equalTo: focusdView.topAnchor, constant: reactionPadding).isActive = true
        reactionHostVC.view.leadingAnchor.constraint(equalTo: focusdView.leadingAnchor, constant: 20).isActive = message.direction == .received
        reactionHostVC.view.trailingAnchor.constraint(equalTo: focusdView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        self.reactionHostVC = reactionHostVC
        
        let messageMenuView = MessageMenuView(message: message)
        let messageMenuHostVC = UIHostingController(rootView: messageMenuView)
        messageMenuHostVC.view.backgroundColor = .clear
        messageMenuHostVC.view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(messageMenuHostVC.view)
        
        var menuPadding: CGFloat = 0
        if shrikCell {
            menuPadding -= (startingFrame.height / 2.5)
        }
        messageMenuHostVC.view.topAnchor.constraint(equalTo: focusdView.bottomAnchor, constant: menuPadding).isActive = true
        messageMenuHostVC.view.leadingAnchor.constraint(equalTo: focusdView.leadingAnchor, constant: 20).isActive = message.direction == .received
        messageMenuHostVC.view.trailingAnchor.constraint(equalTo: focusdView.trailingAnchor, constant: -20).isActive = message.direction == .sent
        
        self.messageMenuVC = messageMenuHostVC
    }
    
    @objc private func dismissContexMenu() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn) { [weak self] in
            guard let self else { return }
            focusdView?.transform = .identity
            focusdView?.frame = startingFrame ?? .zero
            blurView?.alpha = 0
            self.reactionHostVC?.view.removeFromSuperview()
            self.messageMenuVC?.view.removeFromSuperview()

        } completion: { [weak self] _ in
            self?.highlightedCell?.alpha = 1
            self?.blurView?.removeFromSuperview()
            self?.focusdView?.removeFromSuperview()
            
            //Clearing Refrences
            self?.highlightedCell = nil
            self?.blurView = nil
            self?.focusdView = nil
            self?.reactionHostVC = nil
            self?.messageMenuVC = nil

        }
    }
    
    private func shrinkCell(_ cellHeight: CGFloat) -> Bool {
        let screenHeight = (UIWindowScene.current?.screenHeight ?? 0) / 1.2
        let spacingForMenuView = screenHeight - cellHeight
        return spacingForMenuView < 190
    }
}


//#Preview {
//    MessageCollectionController(ChatRoomViewModel(channel: .placeholder))
//}

#Preview {
    NavigationStack {
        MessageCollectionView(viewModel: ChatRoomViewModel(channel: .placeholder))
            .ignoresSafeArea()
            .environmentObject(VoiceMessagePlayer())
    }
}

