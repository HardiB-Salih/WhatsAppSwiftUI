//
//  CallsTabScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import SwiftUI

struct CallsTabScreen: View {
    
    @State private var searchText: String  = ""
    @State private var callHistory = CallHistory.all

    var body: some View {
        NavigationStack {
            List {
                
                Section {
                    CreateCallLinkSection()
                }
                
                Section {
                    ForEach(0.to(12), id: \.self) { _ in
                        RecentCallItemSection()
                    }
                } header: {
                    Text("Recent")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.whatsAppBlack))
                        .textCase(nil)
                }
            }
            .navigationTitle("Calls")
            .searchable(text: $searchText)
            .toolbar {
                leadingNavItem()
                trailingNavItem()
                principalNavItem()
            }
        }
    }
}

#Preview {
    CallsTabScreen()
}

private struct CreateCallLinkSection: View {
    var body: some View {
        HStack {
            Image(systemName: "link")
                .padding(10)
                .background(.thinMaterial)
                .clipShape(Circle())
                .foregroundStyle(.link)
            
            VStack (alignment: .leading){
                Text("Create Call Link")
                    .fontWeight(.semibold)
                    .foregroundStyle(.link)
                
                Text("Share a link for your WhatsApp call.")
                    .font(.footnote)
                    .foregroundStyle(Color(.systemGray))
            }
            
        }
    }
}

private struct RecentCallItemSection: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 45, height: 45)
            
            VStack (alignment: .leading){
                Text("HardiB. Salih")
                    .fontWeight(.bold)
                
                HStack (spacing: 4){
                    Image(systemName: "phone.arrow.up.right.fill")
                    Text("Outgoing")
                        .font(.footnote)
                }
                .foregroundStyle(Color(.systemGray2))
            }
            
            Spacer()
            
            Text("Yesterday")
                .font(.headline)
                .foregroundStyle(Color(.systemGray2))
            
            Image(systemName: "info.circle")
                .foregroundStyle(Color(.darkGray))
            
        }
    }
}


extension CallsTabScreen {
    
    @ToolbarContentBuilder
    private func leadingNavItem()-> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Edit", action: {})
                .tint(.black)
        }
    }
    
    @ToolbarContentBuilder
    private func trailingNavItem()-> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {}, label: {
                Image(systemName: "phone.arrow.up.right")
            }).tint(.black)
        }
    }
    
    @ToolbarContentBuilder
    private func principalNavItem()-> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("", selection: $callHistory) {
                ForEach(CallHistory.allCases) { item in
                    Text(item.title)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
        }
    }
    
    
    private enum CallHistory: String, CaseIterable, Identifiable {
        case all, missed
        var id: String {
            rawValue
        }
        
        var title: String {
            rawValue.capitalized
        }
    }
}
