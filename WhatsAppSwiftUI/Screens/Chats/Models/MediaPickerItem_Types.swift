//
//  MediaPickerItem_Types.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/29/24.
//


import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

struct VideoPickerTransferable: Transferable { // Corrected typo in the name (Vidio -> Video)
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { exportingFile in
            // Exporting logic: return a TransferedFile with the URL
            .init(exportingFile.url)
        } importing: { receivedTransferredFile in
            // Importing logic: handle the received file
            let originalFile = receivedTransferredFile.file
            let uniqueFilename = "\(UUID().uuidString).mov"
            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFilename)
            try FileManager.default.copyItem(at: originalFile, to: copiedFile)
            return .init(url: copiedFile)
        }
    }
}

struct MediaAttachment: Identifiable {
    let id: String
    let type: MediaAtachmentType
    
    var thumbnail: UIImage {
        switch type {
        case .photo(let thumbnail):
            return thumbnail
        case .video(let thumbnail, _ ):
            return thumbnail
        case .audio:
            return UIImage()
        }
    }
}

enum MediaAtachmentType: Equatable {
    case photo(_ thumbnail: UIImage)
    case video(_ thumbnail: UIImage, url: URL)
    case audio
    
    
    static func == (lhs: MediaAtachmentType, rhs: MediaAtachmentType) -> Bool {
        switch (lhs, rhs) {
        case (.photo, .photo), (.video, .video), (.audio, .audio):
            return true
        default:
            return false
            
        }
    }
    
    
}





// Extension to provide URL.documentsDirectory
extension URL {
    static var stubURL: URL {
        return URL(string: "https://google.com")!
    }
    
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func generateVideoThumbnail() async throws -> UIImage? {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        return try await withCheckedThrowingContinuation { continuation in
            imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let cgImage = cgImage {
                    let thumbnailImage = UIImage(cgImage: cgImage)
                    continuation.resume(returning: thumbnailImage)
                } else {
                    continuation.resume(throwing: NSError(domain: "com.example.thumbnail", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate thumbnail"]))
                }
            }
        }
    }
    
//    func generateVideoThubnail() async throws -> UIImage? {
//        let asset = AVAsset(url: self)
//        let imageGenerator = AVAssetImageGenerator(asset: asset)
//        imageGenerator.appliesPreferredTrackTransform = true
//        let time = CMTime(seconds: 1, preferredTimescale: 60)
//        return try await withCheckedContinuation { continuation in
//            imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _ , _ in
//                if let cgImage = cgImage {
//                    let thumbnailImage = UIImage(cgImage: cgImage)
//                    continuation.resume(returning: thumbnailImage)
//                } else {
//                    continuation.resume(throwing: NSError(domain: "", code: 0) as! Never)
//                }
//            }
//        }
//    }
}



//struct VidioPickerTransferable: Transferable {
//    let url: URL
//    static var transferRepresentation: some TransferRepresentation {
//        FileRepresentation(contentType: .movie) { exportingFile in
//            return .init(exportingFile.url)
//        } importing: { receivedTransferredFile in
//            let orignalFile = receivedTransferredFile.file
//            let uniqueFilename = "\(UUID().uuidString).mov"
//            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFilename)
//            try FileManager.default.copyItem(at: orignalFile, to: copiedFile)
//            return .init(url: copiedFile)
//        }
//    }
//}
