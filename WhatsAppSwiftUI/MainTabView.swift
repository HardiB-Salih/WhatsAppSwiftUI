//
//  ContentView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import SwiftUI

struct MainTabView: View {
    
    init(){
        UIHelperManager.makeTabBarOpaque()
    }
    
    var body: some View {
        TabView {
            placeholderItemView("Updates")
                .tabItem {
                    Image(systemName: Tab.updates.icon)
                    Text(Tab.updates.title)
                }
            placeholderItemView("calls")
                .tabItem {
                    Image(systemName: Tab.calls.icon)
                    Text(Tab.calls.title)
                }
            placeholderItemView("communities")
                .tabItem {
                    Image(systemName: Tab.communities.icon)
                    Text(Tab.communities.title)
                }
            placeholderItemView("chats")
                .tabItem {
                    Image(systemName: Tab.chats.icon)
                    Text(Tab.chats.title)
                }
            placeholderItemView("settings")
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
    MainTabView()
}
