//
//  FeedView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import SwiftUI
import CoreLocation
import FirebaseFirestore

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @EnvironmentObject var authVM: AuthViewModel

    @State private var showingUpload = false

    @State private var userHasPostedToday: Bool = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Text("Plate!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)
                            .accessibilityIdentifier("feed_title_label")

                        Button("TEST: Upload Mock Post") {
                            viewModel.uploadMockPost()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        ForEach(viewModel.posts) { post in
                            FeedCardView(post: post,
                                         isLocked: !userHasPostedToday,
                                         viewModel: viewModel)
                        }

                        Spacer().frame(height: 50)
                    }
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
    let isLocked: Bool
    
    let viewModel: FeedViewModel
    

    @State private var cityName: String = "Loading..."

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userID)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)

                    Text(timeAgo(post.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()
                
                Button(action: {
                    print("Delete tapped for post: \(post.id)")  // Add this to confirm it's firing
                    viewModel.deletePost(postID: post.id)
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

            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: post.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
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
                                Text("5")
                                Image(systemName: "star.fill")
                            }
                            .font(.system(size: 16, weight: .bold))
                            Text("Dinner").font(.system(size: 14)).italic()
                        }
                    }
                }
                .padding(25)
                .foregroundColor(.white)
                .background(
                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
                        .cornerRadius(30)
                )

                if isLocked {
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

#Preview {
    FeedView()
}
