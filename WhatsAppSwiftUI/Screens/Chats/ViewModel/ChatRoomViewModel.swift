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
    @Published var isRecordingVoiceMessage = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    
    
    @Published var messages = [MessageItem]()
    @Published var showPhotoPicker: Bool = false
    @Published var photoPickerItems : [PhotosPickerItem] = []
    //    @Published var selectedPhotos : [UIImage] = []
    @Published var mediaAttachments : [MediaAttachment] = []
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false , nil)
    @Published var scrollToBottomRequest: (scroll: Bool, animated: Bool) = (false, false)
    
    var showInnerMic : Bool {
        return mediaAttachments.isEmpty && textMessage.isEmptyOrWhitespaces
    }
    
    var showPhotoPickerPriview: Bool {
        return !mediaAttachments.isEmpty || !photoPickerItems.isEmpty
    }
    
    private var currentUser: UserItem?
    private(set) var channel: ChannelItem
    private var subscritions = Set<AnyCancellable>()
    let voiceRecorderService = VoiceRecorderService()
    
    
    init(channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setupVoiceRecorderListener()
    }
    
    deinit {
        print("ChatViewModel has been deinited")
        subscritions.forEach { $0.cancel() }
        subscritions.removeAll()
        currentUser = nil
        
        //Handle removing audio in file
        voiceRecorderService.tearDown()
        
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
    
    private func setupVoiceRecorderListener() {
        voiceRecorderService.$isRecording.receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                guard let self  else { return }
                self.isRecordingVoiceMessage = isRecording
            }.store(in: &subscritions)
        
        voiceRecorderService.$elaspedTime.receive(on: DispatchQueue.main)
            .sink { [weak self] elaspedTime in
                guard let self  else { return }
                self.elapsedVoiceMessageTime = elaspedTime
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
    
    //MARK: Send Messages
    func sendMessage() {
        guard let currentUser else { return }
        
        if mediaAttachments.isEmpty {
            sendTextMessage(currentUser)
            textMessage = ""
        } else {
            sendMultipleMediaMessages(textMessage, mediaAttachment: mediaAttachments)
            clearTextInputArea()
        }
    }
    
    private func clearTextInputArea() {
        mediaAttachments.removeAll()
        photoPickerItems.removeAll()
        textMessage = ""
        UIApplication.dismissKeyboard()
    }
    
    //MARK: sendTextMessage
    func sendTextMessage(_ currentUser: UserItem) {
        MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) {
            print("Message service is sending")
        }
    }
    
    
    //MARK: sendMultipleMediaMessages
    func sendMultipleMediaMessages(_ text: String, mediaAttachment: [MediaAttachment]){
        mediaAttachment.forEach { attachment in
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: text, attachment: attachment)
            case .video:
                sendVideoMessage(text: text, attachment: attachment)
            case .audio:
                sendVoiceMessage(text: text, attachment: attachment)
            }
        }
    }
    
    //MARK: Send Photo Message
    func sendPhotoMessage(text: String, attachment: MediaAttachment) {
        ///Upload the Image to storage bucket
        uploadImageToStorage(attachment: attachment) { [weak self] imageUrl in
            guard let self = self, let currentUser = currentUser else { return}
            ///Store meta data to our databse
            let uploadParams = MessageUploadParams(channel: channel,
                                                   text: text,
                                                   type: .photo,
                                                   attachment: attachment,
                                                   thumbnailUrl: imageUrl.absoluteString,
                                                   sender: currentUser)
            
            MessageService.sendMediaMessage(toChannel: channel, params: uploadParams) {
                //TODO: Scroll to bottom uplon image upload success
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    //MARK: uploadImageToStorage
    func uploadImageToStorage(attachment: MediaAttachment, completion: @escaping CompletionHandler<URL>) {
        FirebaseHelper.upload(withUIImage: attachment.thumbnail, for: .photoMessage) { result in
            switch result {
            case .success(let url):
                completion(url)
            case .failure(let error):
                print("🙀 Failed to upload image storage: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Upload image Progress \(progress)")
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.animated = animated
    }
    
    
    //MARK: Send Video Message
    func sendVideoMessage(text: String, attachment: MediaAttachment) {
        ///upload video file to the storage
        uploadFileToStorage(attachment: attachment, for: .videoMessage) { [weak self] videoURL in
            guard let self = self, let currentUser else { return}
            self.uploadImageToStorage(attachment: attachment) { imageURL in
                ///Store meta data to our databse
                let uploadParams = MessageUploadParams(channel: self.channel,
                                                       text: text,
                                                       type: .video,
                                                       attachment: attachment,
                                                       thumbnailUrl: imageURL.absoluteString,
                                                       videoUrl: videoURL.absoluteString,
                                                       sender: currentUser)
                MessageService.sendMediaMessage(toChannel: self.channel, params: uploadParams) {
                    //TODO: Scroll to bottom uplon image upload success
                    self.scrollToBottom(animated: true)
                }
            }
        }
    }
    
    //MARK: - Send Voice Messages
    func sendVoiceMessage(text: String, attachment: MediaAttachment) {
        uploadFileToStorage(attachment: attachment, for: .voiceMessage) { [weak self] fileUrl in
            guard let self = self, let currentUser, let audioDuration = attachment.audioDuration else { return}
            ///Store meta data to our databse
            let uploadParams = MessageUploadParams(channel: self.channel,
                                                   text: text,
                                                   type: .audio,
                                                   attachment: attachment,
                                                   audioURL: fileUrl.absoluteString, 
                                                   audioDuration: audioDuration,
                                                   sender: currentUser)
            MessageService.sendMediaMessage(toChannel: self.channel, params: uploadParams) {
                //TODO: Scroll to bottom uplon image upload success
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    
    //MARK: uploadFileToStorage
    func uploadFileToStorage(
        attachment: MediaAttachment,
        for type: FirebaseHelper.UploadType,
        completion: @escaping CompletionHandler<URL>) {
            
        guard let fileURL = attachment.fileURL else { return }
        FirebaseHelper.upload(withFileURL: fileURL , for: type) { result in
            switch result {
            case .success(let url):
                completion(url)
            case .failure(let error):
                print("🙀 Failed to upload file storage: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Upload file Progress \(progress)")
        }
    }
    
    
    
    
    
    func handleInputAreaActions(_ action: TextInputArea.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecorder()
        }
    }
    
    private func toggleAudioRecorder() {
        if voiceRecorderService.isRecording {
            // stop Recording
            voiceRecorderService.stopRecording { [ weak self ] audioURL, audioDuration in
                self?.createAudioAttachment(from: audioURL, audioDuration)
            }
        } else {
            // start Recording
            voiceRecorderService.startRecording()
        }
    }
    
    
    private func createAudioAttachment(from audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    
    
    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [ weak self ] photoItems in
            guard let self else { return }
            // we remove all medea that added to the attachment when the photo picker reshow
            //            self.mediaAttachments.removeAll()
            let audioRecordings = mediaAttachments.filter({ $0.type == .audio(.stubURL, .stubTimeInterval) })
            self.mediaAttachments = audioRecordings
            Task { try await self.parsePhotoPickerItems(photoItems)}
        }.store(in: &subscritions)
    }
    
    @MainActor
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async throws {
        for photosItem in photoPickerItems {
            if photosItem.isVideo {
                // Video Gose Here
                if let movie = try? await photosItem.loadTransferable(type: VideoPickerTransferable.self),
                   let thumbnail = try await movie.url.generateVideoThumbnail(), let itemIdentifier = photosItem.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnail, url: movie.url))
                    self.mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try await photosItem.loadTransferable(type: Data.self),
                    let thumbnail: UIImage = UIImage(data: data),
                    let itemIdentifier = photosItem.itemIdentifier
                else { return }
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
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
        case .remove(let attachment):
            remove(attachment)
            guard let fileURL = attachment.fileURL else { return }
            if attachment.type == .audio(.stubURL, .stubTimeInterval) {
                voiceRecorderService.deleteRecordings(at: fileURL)
            }
        }
    }
    
    
    
    private func remove(_ item: MediaAttachment) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == item.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)
        
        guard let photoIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == item.id }) else { return }
        photoPickerItems.remove(at: photoIndex)
        
    }
    
    
    
    
}
