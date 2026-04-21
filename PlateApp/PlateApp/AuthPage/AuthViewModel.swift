//
//  AuthViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import SwiftUI
import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore



class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    @Published var username = ""
    private var db = Firestore.firestore()
    
    @Published var user: UserInfo? = nil
    
    @MainActor
    private func setError(_ message : String) {
        self.errorMessage = message
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            Task { await MainActor.run {
                setError("Please fill in all fields.")
            }
            }
            return
        }
        Task {
            do {
                let _ = try await AuthenticationManager.shared.signIn(
                                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                    password: password
                                )
                                
                await MainActor.run {
                    withAnimation {
                        self.isAuthenticated = true
                    }
                }
            } catch {
                print(error)
                await MainActor.run {
                    setError("Email or password is incorrect.")
                }
            }
        }
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            Task { await MainActor.run {
                setError("Please fill in all fields.")
            }}
            return
        }
        
        Task {
            let exists = await usernameExists(username)
            
            if exists {
                await MainActor.run {
                    setError("Username already taken.")
                }
                return
            }
            
            
            do {
                let result = try await AuthenticationManager.shared.createUser(email: email, password: password)
                
                let uid = result.uid
                
                let newUser = UserInfo(
                    id: uid,
                    username: username,
                    email: email,
                    profileImageURL: "",
                    createdAt : Date(),
                    updatedAt: Date()
                )
                
                try db.collection("users").document(uid).setData(from: newUser)
                
                await MainActor.run {
                    withAnimation {
                        self.isAuthenticated = true
                    }
                }
            } catch let error as NSError {
                print(error)
                await MainActor.run {
                    if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        setError("This email is already registered.")
                    } else if error.code == AuthErrorCode.invalidEmail.rawValue {
                        setError("Email is badly formatted.")
                    } else {
                        setError("Could not create account. Please try again.")
                    }
                }
            }
        }
    }
    
    
    func signOut() {
        Task {
            do {
                try AuthenticationManager.shared.signOut()
                await MainActor.run {
                    isAuthenticated = false
                }

            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func usernameExists(_ username: String) async -> Bool {
        do {
                let snapshot = try await db.collection("users")
                    .whereField("username", isEqualTo: username)
                    .getDocuments()
                
                return !snapshot.documents.isEmpty
            } catch {
                print("Error checking username: \(error)")
                return true // fail safe (treat as taken)
            }
    }
    
    func createUserInFirestore(uid:String){
        do {
                try db.collection("users").document(uid).setData(from: user)
                
                DispatchQueue.main.async {
                    self.user = self.user
                    self.isAuthenticated = true
                }
                
            } catch {
                self.errorMessage = error.localizedDescription
            }
    }
    
}

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    
    init(user: User)
    {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
    }}


final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {
        
    }
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

