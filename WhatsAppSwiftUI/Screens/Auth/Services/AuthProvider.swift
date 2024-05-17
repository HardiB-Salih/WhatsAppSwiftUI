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
    case failedToLogin(description: String)
    
    var title: String {
        switch self {
        case .accountCreationFailed:
            return "Account Creation Failed"
        case .failedToSaveUserInfo:
            return "Failed to Save User Info"
        case .failedToLogin:
            return "Failed to Log in"
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
        case .failedToLogin(description: let description):
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
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentUserInfo()
            print("🙋‍♂️ \(authResult.user.email ?? "") is Logged In")
        } catch {
            print("🔐 Faild To Log in: \(error.localizedDescription)")
            throw AuthError.failedToLogin(description: error.localizedDescription)
        }
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
        do {
            try Auth.auth().signOut()
            authState.send(.loggedOut)
            print("👋 Succefully logged out")
        } catch {
            print("🔐 Faild To Log out current user: \(error.localizedDescription)")
        }
    }
}


//MARK: -Saving data
extension AuthManager {
    private func saveUserInfoDatabase(user : UserItem) async throws  {
        do {
            // String Constants made in UserItem
            let newDictionary : [String: Any] = [.uid: user.uid, .email: user.email, .username: user.username]
            try await FirebaseConstants.UserRef.child(user.uid).setValue(newDictionary)
        } catch {
            print("🔐 Faild to save user info to Database: \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfo(description: error.localizedDescription)
        }
    }
    
    
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).observe(.value) {[ weak self ] snapshot in
            
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

//MARK: - observe & observeSingleEvent
// observe(EventType.value): This is the most common observation method. It continuously listens for changes in the data at the specified location in your database. Whenever there's a change, your callback function will be triggered with the updated data. This is great for real-time applications like chat rooms or dashboards.

// observeSingleEvent(EventType.value): This method only listens once. It fetches the data at the specified location and then stops listening. It's useful when you need to fetch data just once, like when loading data for an initial display or when you want to avoid unnecessary updates.

//MARK: -[weak self]
// Strong Reference Cycles: In Swift, strong references mean that objects hold onto each other, preventing them from being deallocated. Strong reference cycles can lead to memory leaks if an object can't be released because it's being held by another object that also can't be released.
// weak self Solution: [weak self] creates a weak reference to self. This means that the loggedInUser object doesn't hold self strongly. If the view controller is deallocated, loggedInUser will automatically release its weak reference, preventing the memory leak.
