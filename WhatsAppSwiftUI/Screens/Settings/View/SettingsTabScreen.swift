//
//  SettingsTabScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI
import PhotosUI

struct SettingsTabScreen: View {
    @State private var searchText = ""
    @StateObject private var settingTabViewMode : SettingTabViewMode
    private let currentUser : UserItem
    
    init(_ currentUser : UserItem) {
        self.currentUser = currentUser
        self._settingTabViewMode = StateObject(wrappedValue: SettingTabViewMode(currentUser))
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    profileInfo()
                        .onTapGesture {
                            settingTabViewMode.showUserEnfoEditor = true
                        }
                    PhotosPicker(selection: $settingTabViewMode.selectedPhotoItem, matching: .not(.videos)) {
                        SettingItemView(item: .avatar)
                    }
                }
                
                Section {
                    SettingItemView(item: .broadCastLists)
                    SettingItemView(item: .starredMessages)
                    SettingItemView(item: .linkedDevices)
                }
                
                Section {
                    SettingItemView(item: .account)
                    SettingItemView(item: .privacy)
                    SettingItemView(item: .chats)
                    SettingItemView(item: .notifications)
                    SettingItemView(item: .storage)
                }
                
                Section {
                    SettingItemView(item: .help)
                    SettingItemView(item: .tellFriend)
                }
                
                Section {
                    SettingItemView(item: .logout)
                        .onTapGesture {
                            Task { try? await AuthManager.shared.logOut()}
                        }
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { 
                        settingTabViewMode.uploadProfilePhoto(currentUser.profileImageUrl)
                    }
                        .tint(.black).fontWeight(.bold)
                        .disabled(settingTabViewMode.disableSaveButton)
                }
            }
            .alert(isPresent:  $settingTabViewMode.showProgressHUD, view: settingTabViewMode.progressHUDView)
            .alert(isPresent:  $settingTabViewMode.showSuccessHUD, view: settingTabViewMode.successHUDView)
            .alert("Update Your Profile", isPresented: $settingTabViewMode.showUserEnfoEditor) {
                
                TextField("Usernamw", text: $settingTabViewMode.name)
                TextField("Bio", text: $settingTabViewMode.bio)
                Button("Update") { settingTabViewMode.updateUsernameAndBio()}
                Button("Cancel", role: .cancel) { }

            } message: {
                Text("Enter your new username or bio")
            }

        }
    }
    
    private func profileInfo() -> some View  {
        HStack (alignment: .top){
            
            profileImageView()
            
            VStack (alignment: .leading){
                Text(currentUser.username).bold()
                Text(currentUser.bioUnweappede)
                    .font(.callout)
                    .foregroundStyle(Color(.systemGray2))
            }
            
            Spacer()
            
            Image(.qrcode)
                .renderingMode(.template)
                .padding(6)
                .foregroundStyle(.link)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
    }
    
    @ViewBuilder
    private func profileImageView() -> some View {
        if let profilePhoto = settingTabViewMode.profilePhoto {
            Image(uiImage: profilePhoto.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            CircularProfileImageView(currentUser.profileImageUrl, size: .custom(50))
        }
    }
}

#Preview {
    SettingsTabScreen(.placeholder)
}
