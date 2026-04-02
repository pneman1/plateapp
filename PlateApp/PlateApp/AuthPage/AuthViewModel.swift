//
//  AuthViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import SwiftUI
import Foundation
import FirebaseAuth



class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil
    
    @MainActor
    private func setError(_ message : String) {
        self.errorMessage = message
    }
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            Task { @MainActor in setError("Please fill in all fields.") }
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
                    setError("Username or password is incorrect.")
                }
            }
        }
    }
    
    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            Task { @MainActor in setError("Please fill in all fields.") }
            return
        }
        Task {
            do {
                let _ = try await AuthenticationManager.shared.createUser(email: email, password: password)
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
            } catch {
                print("Error: \(error)")
            }
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

