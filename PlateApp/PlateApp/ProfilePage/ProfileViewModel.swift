//
//  ProfileViewModel.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
}
