//
//  RecommendFriendsView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 4/21/26.
//
import SwiftUI
import Firebase

struct RecommendFriendsView: View {
    @StateObject var viewModel = RecommendationViewModel()
    let currentUserID: String // Pass this in from your Auth state
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ADD RECOMMENDED FRIENDS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ForEach(viewModel.incomingRequests) { user in
                HStack {
                    // Profile Image
                    AsyncImage(url: URL(string: user.profileImageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .fontWeight(.semibold)
                        Text("wants to be your friend")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // add logic to accept request
                    }) {
                        Text("ADD")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .task {
            await viewModel.fetchRecommendations(currentUserID: currentUserID)
        }
    }
}


struct IncomingRequestsView: View {
    @StateObject var viewModel = RecommendationViewModel()
    let currentUserID: String // Pass this in from your Auth state
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("INCOMING REQUESTS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ForEach(viewModel.suggestedUsers) { user in
                HStack {
                    // Profile Image
                    AsyncImage(url: URL(string: user.profileImageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .fontWeight(.semibold)
                        Text("Suggested for you")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.fetchRequests(currentUserID: currentUserID)
                    }) {
                        Text("ADD")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }
        }
        .task {
            await viewModel.fetchRecommendations(currentUserID: currentUserID)
        }
    }
}
