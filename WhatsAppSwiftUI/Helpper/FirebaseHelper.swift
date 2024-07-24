//
//  FirebaseHelper.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 6/9/24.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage


typealias CompletionHandler<T> = (T) -> Void
typealias SimpleCompletionHandler = () -> Void

typealias ResultCompletion<T> = (Result<T, Error>) -> Void
typealias UploadResultCompletion<T, E: Error> = (Result<T, E>) -> Void

extension Int64 {
    var toDouble : Double { Double(self) }
}

enum UploadError: Error {
    case failedToUploadImage(description: String)
    case failedToUploadFile(description: String)

    var title: String {
        switch self {
        case .failedToUploadImage:
            return "Upload Image Failed"
        case .failedToUploadFile:
            return "Upload File Failed"
        }
    }
}

extension UploadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToUploadImage(let description):
            return "\(title): \(description)"
            
        case .failedToUploadFile(let description):
            return "\(title): \(description)"
        }
    }
}


struct FirebaseHelper {
    
    /// Uploads an image to the server.
    ///
    /// - Parameters:
    ///   - image: The UIImage to upload.
    ///   - type: The type of upload.
    ///   - completion: A closure to be executed when the upload completes. It takes a `Result` with a `URL` on success or an `Error` on failure.
    ///   - progressHandler: A closure to be executed periodically to report the progress of the upload. It takes a `Double` value between 0.0 and 1.0 representing the progress.
    static func upload(withUIImage image: UIImage,
                       for type: UploadType,
                       completion: @escaping ResultCompletion<URL>,
                       progressHandler: @escaping CompletionHandler<Double>) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let storageRef = type.filePath
        let uploadTask = storageRef.putData(imageData) { _, error in
            if let error {
                print(UploadError.failedToUploadImage(description: error.localizedDescription))
                completion(.failure(UploadError.failedToUploadImage(description: error.localizedDescription)))
                return
            }
            
            storageRef.downloadURL(completion: completion)
        }
        
        uploadTask.observe(.progress) { storageTaskSnapshot in
            guard let progress = storageTaskSnapshot.progress else { return }
            let percentage = progress.completedUnitCount / progress.totalUnitCount
            progressHandler(percentage.toDouble)
        }
    }
    
    /// Uploads a file from a URL to the server.
    ///
    /// - Parameters:
    ///   - url: The URL of the file to upload.
    ///   - type: The type of upload.
    ///   - completion: A closure to be executed when the upload completes. It takes a `Result` with a `URL` on success or an `Error` on failure.
    ///   - progressHandler: A closure to be executed periodically to report the progress of the upload. It takes a `Double` value between 0.0 and 1.0 representing the progress.
    static func upload(withFileURL url: URL,
                       for type: UploadType,
                       completion: @escaping ResultCompletion<URL>,
                       progressHandler: @escaping CompletionHandler<Double>) {
        
        
        let storageRef = type.filePath
        let uploadTask = storageRef.putFile(from: url) { _, error in
            if let error {
                print(UploadError.failedToUploadFile(description: error.localizedDescription))
                completion(.failure(UploadError.failedToUploadFile(description: error.localizedDescription)))
                return
            }
            
            storageRef.downloadURL(completion: completion)
        }
        
        uploadTask.observe(.progress) { storageTaskSnapshot in
            guard let progress = storageTaskSnapshot.progress else { return }
            let percentage = progress.completedUnitCount / progress.totalUnitCount
            progressHandler(percentage.toDouble)
        }
    }
}

extension FirebaseHelper {
    /// Deletes a file from Firebase Storage using its download URL.
    ///
    /// - Parameter downloadUrl: The download URL of the file to be deleted.
    ///
    /// - Throws: An error if the deletion process fails.
    ///
    /// - Usage Example:
    /// ```swift
    /// do {
    ///     try await deleteFileFromFirebaseStorage(downloadUrl: "https://firebasestorage.googleapis.com:443/v0/b/tinderuikit.appspot.com/o/somefile.jpg?alt=media&token=some-token")
    ///     print("File deleted successfully!")
    /// } catch {
    ///     print("Failed to delete file: \(error.localizedDescription)")
    /// }
    /// ```
    static func deleteFileFromFirebaseStorage(downloadUrl: String) async {
        // Extract the file path from the download URL
        guard let filePath = extractPath(fromUrl: downloadUrl) else { return }
        
        // Create a reference to the file in Firebase Storage
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(filePath)
        
        // Try to delete the file
        do {
            try await fileRef.delete()
            print("File deleted successfully!")
        } catch {
            print("🙀 Could not delete the file at path:\(filePath) because \(error.localizedDescription)")
        }
    }
    
    /// Extracts the path from a Firebase Storage download URL.
    ///
    /// - Parameter url: The download URL from which to extract the path.
    ///
    /// - Returns: A `String?` containing the extracted path if successful, or `nil` if the URL does not match the expected pattern.
    ///
    /// - Usage Example:
    /// ```swift
    /// if let path = extractPath(fromUrl: "https://firebasestorage.googleapis.com:443/v0/b/tinderuikit.appspot.com/o/somefile.jpg?alt=media&token=some-token") {
    ///     print("Extracted path: \(path)")
    /// } else {
    ///     print("Failed to extract path")
    /// }
    /// ```
    static func extractPath(fromUrl url: String) -> String? {
        let storageRef = Storage.storage().reference()
        let pattern = "https://firebasestorage.googleapis.com:443/v0/b/\(storageRef.bucket)/o/"
        
        guard let range = url.range(of: pattern) else { return nil }
        let pathPart = url[range.upperBound...]
        
        if let queryIndex = pathPart.range(of: "?")?.lowerBound {
            let encodedPath = String(pathPart[..<queryIndex])
            return encodedPath.removingPercentEncoding
        }
        return nil
    }
}

extension FirebaseHelper {
    enum UploadType {
        case profilePhoto
        case photoMessage
        case videoMessage
        case voiceMessage
        
        
        var filePath: StorageReference {
            let filename = UUID().uuidString.lowercased()
            switch self {
            case .profilePhoto:
                return FirebaseConstants.StorageReference.child("profile_photos").child(filename)
            case .photoMessage:
                return FirebaseConstants.StorageReference.child("photo_message").child(filename)
            case .videoMessage: 
                return FirebaseConstants.StorageReference.child("video_message").child(filename)
            case .voiceMessage:
                return FirebaseConstants.StorageReference.child("voice_message").child(filename)
            }
        }
    }
}
