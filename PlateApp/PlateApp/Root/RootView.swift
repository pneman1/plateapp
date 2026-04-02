//
//  RootView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/25/26.
//
import SwiftUI

struct RootView: View {
    @StateObject var authVM = AuthViewModel()
    
    var body: some View {
        Group {
            if authVM.isAuthenticated {
                MainTabView()
                    .environmentObject(authVM)
            }
            else {
                NavigationStack {
                    AuthView()
                }
                .environmentObject(authVM)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
