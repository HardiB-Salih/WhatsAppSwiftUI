//
//  ContentView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import SwiftUI

struct MainTabView: View {
    
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem){
        self.currentUser = currentUser
        UIHelperManager.makeTabBarOpaque()
        let thunbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thunbImage, for: .normal)
    }
    
    var body: some View {
        TabView {
            UpadatesTabScreen()
                .tabItem {
                    Image(systemName: Tab.updates.icon)
                    Text(Tab.updates.title)
                }
            CallsTabScreen()
                .tabItem {
                    Image(systemName: Tab.calls.icon)
                    Text(Tab.calls.title)
                }
            CommunitiesTabScreen()
                .tabItem {
                    Image(systemName: Tab.communities.icon)
                    Text(Tab.communities.title)
                }
            ChannelTabScreen()
                .tabItem {
                    Image(systemName: Tab.chats.icon)
                    Text(Tab.chats.title)
                }
            SettingsTabScreen()
                .tabItem {
                    Image(systemName: Tab.settings.icon)
                    Text(Tab.settings.title)
                }
        }
    }
}

extension MainTabView {
    private func placeholderItemView(_ title: String) -> some View {
        Text(title)
            .font(.title)
    }
    
    
    private enum Tab : String {
        case updates, calls, communities, chats, settings
        
        
        fileprivate var title: String {
            return rawValue.capitalized
        }
        fileprivate var icon: String {
            switch self {
            case .updates: return "circle.dashed.inset.filled"
            case .calls: return "phone"
            case .communities: return "person.3"
            case .chats: return "message"
            case .settings: return "gear"
            }
        }
    }
}


#Preview {
    MainTabView(.placeholder)
}
