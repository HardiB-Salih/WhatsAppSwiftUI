//
//  CircularProfileImageView.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/19/24.
//

import SwiftUI
import Kingfisher

struct CircularProfileImageView: View {
    var profileImageUrl : String?
    var size: Size
    var fallbackImage: FallbackImage = .directChatIcon
    
    init(_ profileImageUrl: String? = nil,
         size: Size) {
        self.profileImageUrl = profileImageUrl
        self.size = size
    }
    
    var body: some View {
        if let profileImageUrl {
            KFImage(URL(string: profileImageUrl))
                .resizable()
                .placeholder({
                    ProgressView()
                })
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            placeholderImageView()
        }
    }
    
    private func placeholderImageView() -> some View {
        Image(systemName: fallbackImage.rawValue)
            .resizable()
            .scaledToFill()
            .imageScale(.large)
            .frame(width: size.dimension, height: size.dimension)
            .foregroundStyle(Color(.systemGray4))
            .overlay {
                Circle().stroke(Color(.systemGray4), lineWidth: 1.0)
            }
            .clipShape(Circle())
    }
}

#Preview {
    CircularProfileImageView(size: .large)
}

extension CircularProfileImageView {
    enum FallbackImage: String {
        case directChatIcon = "person.circle.fill"
        case groupChatIcon = "person.2.circle.fill"
        
        init(for membersCount: Int) {
            switch membersCount {
            case 2:
                self = .directChatIcon
            default:
                self = .groupChatIcon
            }
        }
    }
}


extension CircularProfileImageView {
    init(_ channel: ChannelItem, size: Size) {
        self.profileImageUrl = channel.coverImageUrl
        self.size = size
        self.fallbackImage = FallbackImage(for: channel.membersCount)
    }
}






enum Size{
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case custom(CGFloat)
    
    // MARK: - Computed Properties for Flexible Sizing
    var dimension: CGFloat {
        switch self {
        case .xxSmall:
            return SizeDimensions.xxSmall
        case .xSmall:
            return SizeDimensions.xSmall
        case .small:
            return SizeDimensions.small
        case .medium:
            return SizeDimensions.medium
        case .large:
            return SizeDimensions.large
        case .xLarge:
            return SizeDimensions.xLarge
        case .custom(let size):
            return size
        }
    }
}

private struct SizeDimensions {
        static let xxSmall: CGFloat = 30
        static let xSmall: CGFloat = 40
        static let small: CGFloat = 50
        static let medium: CGFloat = 60
        static let large: CGFloat = 80
        static let xLarge: CGFloat = 120
    
//    static let xxSmall: CGFloat = 28
//    static let xSmall: CGFloat = 32
//    static let small: CGFloat = 40
//    static let medium: CGFloat = 48
//    static let large: CGFloat = 64
//    static let xLarge: CGFloat = 80
}
