//
//  FeedView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import SwiftUI
import CoreLocation
import FirebaseFirestore
import Kingfisher

struct FeedView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var selectedTab: Int
    @StateObject private var viewModel = FeedViewModel()
    @State private var showingUpload = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Text("Plate!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .accessibilityIdentifier("feed_title_label")
                        
                        ForEach(viewModel.posts) { post in
                            FeedCardView(post: post,
                                         viewModel: viewModel)
                        }

                        Spacer().frame(height: 50)
                        VStack(spacing: 20) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.accentColor.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "person.badge.plus")
                                            .font(.system(size: 30, weight: .semibold))
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        Text("You're all caught up!")
                                            .font(.headline)
                                        
                                        Text("Add more friends to see what they're eating today.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                    }
                                    
                                    Button(action: {
                                        selectedTab = 2
                                    }) {
                                        Text("Find Friends")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(Color.accentColor)
                                        .cornerRadius(20)
                                    }
                                }
                                .padding(.vertical, 40)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 24)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                        .foregroundStyle(.quaternary)
                                }
                                .padding(.horizontal, 24)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingUpload = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showingUpload) {
                UploadView()
            }
        }
    }
}

struct FeedCardView: View {
    let post: Post
    @ObservedObject var viewModel: FeedViewModel
    @EnvironmentObject var authVM: AuthViewModel
    

    @State private var cityName: String = "Loading..."
    @State private var showingDeleteAlert: Bool = false
    @State private var pendingDeletePostID: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                // Profile avatar: use cached URL if available, otherwise fallback to system placeholder
                VStack(spacing: 4) {
                    if let url = viewModel.userProfileURLs[post.userID] {
                        KFImage(url)
                            .onFailure { err in
#if DEBUG
                                print("KFImage avatar failed for uid=\(post.userID) url=\(url.absoluteString) error=\(err.localizedDescription)")
#endif
                            }
                            .placeholder {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .resizable()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.gray)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    Text(timeAgo(post.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Show delete button only for the user's own posts
                if post.userID == authVM.user?.id {
                    Button(action: {
                        // Defer actual deletion until user confirms
                        pendingDeletePostID = post.id
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(12)           // Even bigger hit area
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Circle())        // Explicitly define tappable area
                    .zIndex(100)                   // Much higher to ensure it's on top
                    .alert("Delete Post?", isPresented: $showingDeleteAlert, presenting: pendingDeletePostID) { postID in
                        Button("Delete", role: .destructive) {
                            print("Confirmed delete for post: \(postID)")
                            viewModel.deletePost(postID: postID)
                            Task {
                                await authVM.setHasPosted(flag: false)
                            }
                            pendingDeletePostID = nil
                        }
                        Button("Cancel", role: .cancel) {
                            pendingDeletePostID = nil
                        }
                    } message: { _ in
                        Text("Are you sure you want to delete this post? This action cannot be undone.")
                    }
                }

            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ZStack(alignment: .bottom) {
                KFImage(URL(string: post.imageURL))
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView().tint(.white))
                    }
                    .retry(maxCount: 3, interval: .seconds(1))
                    .cacheOriginalImage()
                    .onFailure { error in
#if DEBUG
                        print("Image failed to load: \(error.localizedDescription)")
#endif
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 500)
                    .clipShape(RoundedRectangle(cornerRadius: 30))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.location.restaurantName)
                                .font(.system(size: 20, weight: .semibold))
                            Text(cityName)
                                .font(.system(size: 14, weight: .medium))
                                .italic()
                                .accessibilityIdentifier("post_city_label")
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("\(post.rating)")
                                Image(systemName: "star.fill")
                            }
                            .font(.system(size: 16, weight: .bold))
                            Text(post.mealType).font(.system(size: 14)).italic()
                        }
                    }
                }
                .padding(25)
                .foregroundColor(.white)
                .background(
                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
                        .cornerRadius(30)
                )

                if !(authVM.user?.hasPosted ?? false) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            VStack {
                                Image(systemName: "lock.fill").font(.largeTitle)
                                Text("Post to Unlock").font(.headline)
                            }
                            .foregroundColor(.white)
                        )
                        .allowsHitTesting(false)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
            }
            .allowsHitTesting(false)
            .onAppear {
                let coordinate = CLLocationCoordinate2D(
                    latitude: post.location.geopoint.latitude,
                    longitude: post.location.geopoint.longitude
                )

                LocationHelper.shared.getCityName(from: coordinate) { locationString in
                    DispatchQueue.main.async {
                        self.cityName = locationString
                    }
                }
            }
        }
    }
    

    func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

