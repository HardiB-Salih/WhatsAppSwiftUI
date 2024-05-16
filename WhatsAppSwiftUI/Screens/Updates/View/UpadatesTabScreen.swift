//
//  UpadatesTabScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import SwiftUI

struct UpadatesTabScreen: View {
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            
            List {
                Section {
                    StatusSeactionHeader()
                        .listRowBackground(Color.clear)
                } header: {
                    Text("Status")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.whatsAppBlack))
                        .textCase(nil)
                }
                
                StatusSeaction()
                
                Section {
                    RecentStatusSeaction()
                } header: {
                    Text("RECENT UPDATES")
                }
                
                Section {
                    ChannelListView()
                } header: {
                    channelSectionHeader()
                }
                
                
                
            }
            .listStyle(.grouped)
            .listRowSeparator(.hidden)
            .navigationTitle("Updates")
            .searchable(text: $searchText)
            
        }
    }
    
    
    
}


private struct StatusSeactionHeader: View {
    var body: some View {
        HStack (alignment: .top){
            Image(systemName: "circle.dashed")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.link)
                .frame(width: 24, height: 24)
            (
                Text("Use Status to share photops, text and video that disappear in 24 hours.")
                +
                Text(" ")
                +
                Text("Status Privacy")
                    .foregroundStyle(.link).bold()
            )
            
            Button(action: {}, label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.black)
            })
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10 , style: .continuous))
        
    }
}





private struct  StatusSeaction: View {
    var body: some View {
        HStack (alignment: .center){
            Circle()
                .frame(width: 60, height: 60)
            
            VStack (alignment: .leading) {
                Text("My Status")
                    .fontWeight(.bold)
                
                Text("Add to my status")
                    .font(.subheadline)
                    .foregroundStyle(Color(.systemGray))
            }
            
            Spacer()
            
            Button(action: {}, label: {
                Image(systemName: "camera.fill")
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                    .foregroundStyle(Color(.black))
            })
            
            Button(action: {}, label: {
                Image(systemName: "pencil")
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                    .foregroundStyle(Color(.black))
            })
            
        }
    }
}

private struct RecentStatusSeaction: View {
    var body: some View {
        HStack (alignment: .center){
            Circle()
                .frame(width: 60, height: 60)
            
            VStack (alignment: .leading) {
                Text("HardiB. Salih")
                    .fontWeight(.bold)
                
                Text("1h ago")
                    .font(.subheadline)
                    .foregroundStyle(Color(.systemGray))
            }
            
            Spacer()
            
        }
    }
}

private struct ChannelListView: View {
    var body: some View {
        VStack (alignment: .leading ) {
            Text("State updated on topic that matter to you. Find channels to follow below.")
                .font(.callout)
                .foregroundStyle(Color(.systemGray))
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<5) { _ in
                        SuggestedChannelItemView()
                    }
                }
            }.padding(.vertical)
            
            Button("Explore more", action: { })
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(8)
                .background(Color(.link))
                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            
        }
    }
}


private struct SuggestedChannelItemView: View {
    var body: some View {
        VStack (spacing: 8){
            Circle()
                .frame(width: 60, height: 60)
            
            Text("Surrey, BC")
                .font(.callout)
                .foregroundStyle(Color(.systemGray))
                .padding(.horizontal)
            
            Button("Follow", action: { })
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding(5)
                .frame(maxWidth: .infinity)
                .background(Color(.link).opacity(0.2))
                .clipShape(Capsule())
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(.systemGray3), lineWidth: 2.0)
        }
    }
}

#Preview {
    UpadatesTabScreen()
}

extension UpadatesTabScreen {
    private func channelSectionHeader() -> some View {
        HStack (alignment: .top){
            Text("Channels")
                .font(.title3)
                .bold()
                .foregroundStyle(Color(.whatsAppBlack))
                .textCase(nil)
            
            Spacer()
            Button(action: {}, label: {
                Image(systemName: "plus")
                    .padding(5)
                    .background(Color(.systemGray3))
                    .clipShape(Circle())
                    .foregroundStyle(Color(.black))
            })
            
        }.padding(.vertical, 2)
    }
}
