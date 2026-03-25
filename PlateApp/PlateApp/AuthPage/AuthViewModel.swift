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
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email or Password Found.")
            return
        }
        Task {
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print("Success")
                print(returnedUserData)
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
}

