//
//  CommunitiesTabScreen.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/15/24.
//

import SwiftUI

struct CommunitiesTabScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading, spacing: 10){
                    Image(.communities)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    Group {
                        Text("Stay connected with a community")
                            .font(.title2)
                        
                        Text("Communities bring members together in topic-based groups. Any community you're added to will appear here.")
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Button("See example comunites >", action: {})
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.black)
                    
                    Button(action: {}, label: {
                        Label("New Community", systemImage: "plus")
                            .foregroundStyle(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(.link)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    })
                    
                    
                    
                }.padding(.horizontal)
                
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Communities")
        }
    }
}

#Preview {
    CommunitiesTabScreen()
}
