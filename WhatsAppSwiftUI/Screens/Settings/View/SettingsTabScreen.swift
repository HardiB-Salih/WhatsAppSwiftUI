//
//  SettingsTabScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/16/24.
//

import SwiftUI

struct SettingsTabScreen: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    profileInfo()
                    SettingItemView(item: .avatar)
                }.lineLimit(1)
                
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
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { }
                        .tint(.black).fontWeight(.bold)
                }
            }
        }
    }
    
    private func profileInfo() -> some View  {
        HStack (alignment: .top){
            Circle()
                .frame(width: 50, height: 50)
            
            VStack (alignment: .leading){
                Text("HardiB. Salih").bold()
                Text("Hey there! I am using whatsApp")
                    .font(.caption)
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
}

#Preview {
    SettingsTabScreen()
}
