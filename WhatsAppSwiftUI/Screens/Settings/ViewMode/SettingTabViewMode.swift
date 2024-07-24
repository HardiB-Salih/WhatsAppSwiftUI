//
//  SettingTabViewMode.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 7/24/24.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine
import Firebase
import FirebaseDatabase
import AlertKit

@MainActor
final class SettingTabViewMode: ObservableObject {
    @Published var selectedPhotoItem : PhotosPickerItem?
    @Published var profilePhoto: MediaAttachment?
    @Published var showProgressHUD = false
    @Published var showSuccessHUD = false
    @Published var showUserEnfoEditor = false
    @Published var name = ""
    @Published var bio = ""
    
    private var currentUser: UserItem
    
    private(set) var progressHUDView = AlertAppleMusic17View(title: "Uploading Profile Photo", subtitle: nil, icon: .spinnerSmall)
    private(set) var successHUDView = AlertAppleMusic17View(title: "Profile Info Updated", subtitle: nil, icon: .done)
    
    private var subscription: AnyCancellable?
    var disableSaveButton: Bool {
        return profilePhoto == nil || showProgressHUD
    }
    
    
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        self.name = currentUser.username
        self.bio = currentUser.bio ?? ""
        
        onPhotoPickerSelection()
    }
    
    //MARK: Subscribe to PhotosPickerItem
    private func onPhotoPickerSelection() {
        subscription = $selectedPhotoItem
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] photoItem in
                guard let photoItem, let self else { return }
                self.parsePhotoPickerItem(photoItem)
            })
    }
    
    //MARK: Convert PhotosPickerItem to MediaAttachment
    private func parsePhotoPickerItem(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            
            self.profilePhoto = MediaAttachment(id: UUID().uuidString, type: .photo(uiImage))
        }
    }
    
    
    //MARK: Upload the MediaAttachment photo to firebase
    func uploadProfilePhoto(_ currentProfileUrl: String?) {
        guard let profilePhoto = profilePhoto?.thumbnail else { return }
        showProgressHUD = true
        ///delete currentProfileUrl from the storage bucket if exist
        if let currentProfileUrl {
            Task {
                await FirebaseHelper.deleteFileFromFirebaseStorage(downloadUrl: currentProfileUrl)
            }
        }
        
        /// upload new photo to the storage bucket
        FirebaseHelper.upload(withUIImage: profilePhoto, for: .profilePhoto) {[weak self] result in
            switch result {
            case .success( let imageUrl):
                self?.onUploadSuccess(imageUrl)
            case .failure(let error):
                print("Faild to upload: \(error.localizedDescription)")
                
            }
        } progressHandler: { progress in
            print("Uploaded Image Progress: \(progress)")
        }
    }
    
    
    
    //MARK: Upload the photo to firebase Database
    private func onUploadSuccess(_ imageUrl: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).child("profileImageUrl").setValue(imageUrl.absoluteString)
        showProgressHUD = false
        progressHUDView.dismiss()
        ///refreshing the current user manually not using observer
        currentUser.profileImageUrl = imageUrl.absoluteString
        AuthManager.shared.authState.send(.loggedIn(currentUser))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
            self.showSuccessHUD = true
            self.profilePhoto = nil
            self.selectedPhotoItem = nil
        }
        print("profileImageUrl: Upload Sucsefully")
    }
    
    
    //MARK: Upload the Username and Bio
    func updateUsernameAndBio() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var dict: [String: Any] = [ .bio: bio ]
        currentUser.bio = bio
        
        if name.isNotEmptyOrWhitespaces {
            dict[.username] = name
            currentUser.username = name
        }
        
        FirebaseConstants.UserRef.child(currentUid).updateChildValues(dict) { error, _ in
            if let error = error {
                print("Failed to update user data: \(error.localizedDescription)")
            } else {
                print("Successfully updated user data")
            }
        }
        showSuccessHUD = true
        
        ///refreshing the current user manually not using observer
        AuthManager.shared.authState.send(.loggedIn(currentUser))
    }
    
}
