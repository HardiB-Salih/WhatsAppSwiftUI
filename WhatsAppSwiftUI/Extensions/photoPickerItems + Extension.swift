//
//  photoPickerItems + Extension.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/29/24.
//

import Foundation
import PhotosUI
import SwiftUI

extension PhotosPickerItem {
    var isVideo: Bool {
        let videoUTTypes: [UTType] = [
            .avi,
            .video,
            .mpeg2Video,
            .mpeg4Movie,
            .movie,
            .quickTimeMovie,
            .audiovisualContent,
            .mpeg,
            .appleProtectedMPEG4Video
        ]
        
        return videoUTTypes.contains(where: supportedContentTypes.contains)
    }
}


//extension PhotosPickerItem {
//    var isVideo: Bool {
//        get async {
//            // Define a list of known video UTTypes
//            let videoUTTypes: [UTType] = [
//                .avi,
//                .video,
//                .mpeg2Video,
//                .mpeg4Movie,
//                .movie,
//                .quickTimeMovie,
//                .audiovisualContent,
//                .mpeg,
//                .appleProtectedMPEG4Video
//            ]
//
//            do {
//                // Attempt to load the item's content type as a UTType
//                if let typeIdentifier = try await self.loadTransferable(type: String.self) {
//                    if let itemType = UTType(typeIdentifier) {
//                        // Check if the item type conforms to any known video UTType
//                        return videoUTTypes.contains { itemType.conforms(to: $0) }
//                    }
//                }
//            } catch {
//                // Handle potential errors (e.g., loading failed)
//                print("Failed to load type identifier: \(error)")
//            }
//
//            return false
//        }
//    }
//}
