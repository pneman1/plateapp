//
//  ProfileView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    private let gridItems = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    if let profile = viewModel.profileSummary {
                        profileHeader(profile)
                        statsSection(profile)
                        profileDataSection(profile)
                    } else if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Button("Log Out") {
                        authVM.signOut()
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.primary))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .accessibilityIdentifier("profileLogOutButton")

                    historySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .sheet(isPresented: Binding(get: { viewModel.isShowingImagePicker }, set: { viewModel.isShowingImagePicker = $0 })) {
            CameraPicker(image: Binding(get: { viewModel.selectedImage }, set: { viewModel.selectedImage = $0 }))
        }
        .onReceive(viewModel.$selectedImage) { img in
            if let img = img {
                viewModel.uploadProfileImage(image: img)
                // clear selected image to avoid re-upload on view redraws
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.selectedImage = nil
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func profileHeader(_ profile: ProfileSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 82, height: 82)

                    if let urlString = profile.profileImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                                .tint(.white)
                        }
                        .frame(width: 82, height: 82)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(.white)
                    }
                }
                .onTapGesture {
                    // show image picker to change profile image
                    viewModel.isShowingImagePicker = true
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.displayName)
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.white)

                    Text(profile.email)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray)

                    Text("Joined \(profile.joinedDate)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
    }

    // ...existing code...

    private func statsSection(_ profile: ProfileSummary) -> some View {
        HStack(spacing: 12) {
            profileStatCard(title: "Posts", value: "\(profile.totalPosts)")
            profileStatCard(title: "Public", value: "\(profile.publicPosts)")
            profileStatCard(title: "Private", value: "\(profile.privatePosts)")
        }
    }

    private func profileDataSection(_ profile: ProfileSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile Data")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 10) {
                profileDataRow(label: "Favorite Spot", value: profile.favoriteSpot)
                profileDataRow(label: "Current History Count", value: "\(viewModel.posts.count) posts")
                profileDataRow(label: "Account Status", value: "Active")
            }
            .padding(18)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Post History")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            if viewModel.posts.isEmpty, !viewModel.isLoading {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No post history yet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)

                    Text("Your posts will appear here once they match the signed-in account data.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 22))
            } else {
                LazyVGrid(columns: gridItems, spacing: 12) {
                    ForEach(viewModel.posts) { post in
                        ProfileHistoryCard(post: post)
                    }
                }
            }
        }
    }

    private func profileStatCard(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func profileDataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.gray)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

private struct ProfileHistoryCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: post.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 165)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(alignment: .leading, spacing: 4) {
                Text(post.locationString)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(post.dateString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.gray)
                    .lineLimit(1)

                Text(post.caption)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
