//
//  ChatRoomViewModel.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import SwiftUI
import Combine
import PhotosUI

final class ChatRoomViewModel : ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    
    @Published var showPhotoPicker: Bool = false
    @Published var photoPickerItems : [PhotosPickerItem] = []
//    @Published var selectedPhotos : [UIImage] = []
    @Published var mediaAttachments : [MediaAttachment] = []
    
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false , nil)
    
    
    
    
    
    var showPhotoPickerPriview: Bool {
        return !mediaAttachments.isEmpty
    }
    
    private var currentUser: UserItem?
    private(set) var channel: ChannelItem
    private var subscritions = Set<AnyCancellable>()
    
    
    init(channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
    }
    
    deinit {
        subscritions.forEach { $0.cancel() }
        subscritions.removeAll()
        currentUser = nil
    }
    

    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink {[weak self] authState in
            guard let self = self else { return } // we have to make sure the context is there

            switch authState {
            case .loggedIn(let currentUser):
                self.currentUser = currentUser
                if self.channel.allmemberFetched {
                    self.getMessages()
                } else {
                    self.getAllChannelMembers()
                }
                
            default:
                break
            }
        }.store(in: &subscritions)
    }
    

    
    
    private func getMessages() {
        MessageService.getMessages(for: channel) { messages in
            self.messages = messages
            print("message: \(messages.map { $0.text })")
        }
    }
    
    
    
    private func getAllChannelMembers() {
        /// We already have current user, and potentionally 2 other members so no need to refetch thoes
        guard let currentUser = currentUser else { return }
        let membersAlreadyFetchedUid = channel.members.compactMap({ $0.uid })
        var memberUidToFetch = channel.membersUids.filter({ !membersAlreadyFetchedUid.contains($0)} )
        memberUidToFetch = memberUidToFetch.filter({ $0 != currentUser.uid})
        
        
        UserServices.getUsers(with: memberUidToFetch) {[ weak self ] userNode in
            guard let self = self else { return } // we have to make sure the context is there
            self.channel.members.append(contentsOf: userNode.users)
            self.getMessages()
            print("𐑼 getAllChannelMembers: \(channel.members.map ({ $0.username }))")
        }
    }
    
    
    func sendMessageOrAudio() {
        if textMessage.isEmptyOrWhitespaces {
            // Send audio
            print("Send audio")
        } else {
            
        }
    }
    
    
    func sendTextMessage() {
        guard let currentUser else { return }
        MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) { [weak self] in
            print("Message service is sending")
            self?.textMessage = ""
        }
    }
    
    
    func handleInputAreaActions(_ action: TextInputArea.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendTextMessage()
        case .sendAudio:
            print("Send audio")
        }
    }
    
    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [ weak self ] photoItems in
            guard let self else { return }
            // we remove all medea that added to the attachment when the photo picker reshow
            self.mediaAttachments.removeAll()
            Task { try await self.parsePhotoPickerItems(photoItems)}
        }.store(in: &subscritions)
    }
    
    @MainActor
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async throws {
        for photosItem in photoPickerItems {
            if photosItem.isVideo {
                // Video Gose Here
                if let movie = try? await photosItem.loadTransferable(type: VideoPickerTransferable.self),
                    let thumbnail = try await movie.url.generateVideoThumbnail() {
                    let videoAttachment = MediaAttachment(id: UUID().uuidString, type: .video(thumbnail, url: movie.url))
                    self.mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try await photosItem.loadTransferable(type: Data.self),
                    let thumbnail: UIImage = UIImage(data: data)
                else { return }
                let photoAttachment = MediaAttachment(id: UUID().uuidString, type: .photo(thumbnail))
                self.mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }
    
    
    func dismissMediaPlayer(){
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
    }
    
    func showMediaPlayer(_ fileURL: URL){
        videoPlayerState.show = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }
    
    func handlleMediaAttachmentPriview(_ action: MediaAtachmentPreview.UserAction) {
        switch action {
        case .play(let attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediaPlayer(fileURL)
        }
    }
}
