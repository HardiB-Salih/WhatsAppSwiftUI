//
//  AuthProvider.swift
//  WhatsAppSwiftUI
//
//  Created by HardiB.Salih on 5/17/24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase
import FirebaseDatabaseSwift

//MARK: -ENUMs
enum AuthState {
    case pending, loggedIn(UserItem), loggedOut
}

enum AuthError: Error {
    case accountCreationFailed(description: String)
    case failedToSaveUserInfo(description: String)
    
    var title: String {
        switch self {
        case .accountCreationFailed:
            return "Account Creation Failed"
        case .failedToSaveUserInfo:
            return "Failed to Save User Info"
        }
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailed(let description):
            return "\(title): \(description)"
        case .failedToSaveUserInfo(let description):
            return "\(title): \(description)"
        }
    }
}



//MARK: -AuthProvider
/// A protocol defining the necessary methods and properties for handling user authentication.
///
/// Conforming types provide functionality to log in, log out, create an account,
/// and manage the authentication state.
///
/// - Note: This protocol uses the Combine framework to publish authentication state changes.
protocol AuthProvider {
    
    /// The shared instance of the authentication provider.
    static var shared: AuthProvider { get }
    
    /// The current authentication state, published via Combine's `CurrentValueSubject`.
    var authState: CurrentValueSubject<AuthState, Never> { get }
    
    /// Attempts to automatically log in the user, updating the authentication state.
    func autoLogin() async
    
    /// Logs in the user with the provided email and password.
    ///
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The password of the user.
    /// - Throws: An error if the login fails.
    func login(with email: String, password: String) async throws
    
    /// Creates a new account with the provided username, email, and password.
    ///
    /// - Parameters:
    ///   - username: The desired username.
    ///   - email: The email address of the user.
    ///   - password: The desired password.
    /// - Throws: An error if the account creation fails.
    func createAccount(for username: String, email: String, password: String) async throws
    
    /// Logs out the current user, updating the authentication state.
    ///
    /// - Throws: An error if the logout process fails.
    func logOut() async throws
}


//MARK: -AuthManager
final class AuthManager: AuthProvider {
    private init(){
        Task { await autoLogin() }
    }
    static let shared: AuthProvider = AuthManager()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    func autoLogin() async {
        if Auth.auth().currentUser == nil {
            self.authState.send(.loggedOut)
        } else {
            fetchCurrentUserInfo()
        }
    }
    
    func login(with email: String, password: String) async throws {
        
    }
    
    func createAccount(for username: String, email: String, password: String) async throws {
        do {
            // invoke firebase create account method: store the suer in out firebase auth
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            //store new user in out database
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            try await saveUserInfoDatabase(user: newUser)
            
            //This is publish the new user information with this call
            self.authState.send(.loggedIn(newUser))
        } catch {
            print("🔐 Faild To Create An Account: \(error.localizedDescription)")
            throw AuthError.accountCreationFailed(description: error.localizedDescription)

        }
    }
    
    func logOut() async throws {
        
    }
}


//MARK: -Saving data
extension AuthManager {
    private func saveUserInfoDatabase(user : UserItem) async throws  {
        do {
            let newDictionary = ["uid": user.uid, "email": user.email, "username": user.username]
            try await Database.database().reference().child("users").child(user.uid).setValue(newDictionary)
        } catch {
            print("🔐 Faild to save user info to Database: \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfo(description: error.localizedDescription)
        }
    }
    
    
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(currentUid).observe(.value) {[ weak self ] snapshot in
            
            guard let userDict = snapshot.value as? [String: Any] else { return }
            let loggedInUser = UserItem(dictionary: userDict)
            
            //This is publish the user information
            self?.authState.send(.loggedIn(loggedInUser))
            print("🙋‍♂️ \(loggedInUser.username) is Logged In")
            
        } withCancel: { error in
            print("🔐 Faild to get current user Info: \(error.localizedDescription)")
        }
    }
}



//MARK: -UserItem
struct UserItem: Identifiable, Decodable, Hashable {
    let uid: String
    let username: String
    let email: String
    var bio: String? = nil
    var profileImageUrl: String? = nil
    
    var id: String {
        return uid
    }
    
    var bioUnweappede: String {
        return bio ?? "Hey there! I am using AhatsApp."
    }
}

extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String? ?? nil
        self.profileImageUrl = dictionary[.profileImageUrl] as? String? ?? nil
    }
}

extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageUrl = "profileImageUrl"
}

//MARK: - observe & observeSingleEvent
// observe(EventType.value): This is the most common observation method. It continuously listens for changes in the data at the specified location in your database. Whenever there's a change, your callback function will be triggered with the updated data. This is great for real-time applications like chat rooms or dashboards.

// observeSingleEvent(EventType.value): This method only listens once. It fetches the data at the specified location and then stops listening. It's useful when you need to fetch data just once, like when loading data for an initial display or when you want to avoid unnecessary updates.

//MARK: -[weak self]
// Strong Reference Cycles: In Swift, strong references mean that objects hold onto each other, preventing them from being deallocated. Strong reference cycles can lead to memory leaks if an object can't be released because it's being held by another object that also can't be released.
// weak self Solution: [weak self] creates a weak reference to self. This means that the loggedInUser object doesn't hold self strongly. If the view controller is deallocated, loggedInUser will automatically release its weak reference, preventing the memory leak.
