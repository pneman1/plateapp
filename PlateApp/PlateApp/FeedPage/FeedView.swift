//
//  FeedView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//
import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @EnvironmentObject var authVM: AuthViewModel
    
//    let mockPosts: [Post] = [
//        Post(
//            id: "1",
//            authorID: "rwind13",
//            imageURL: "https://i.imgur.com/RpzNeWO.jpeg",
//            caption: "Best banana bread in Philly!",
//            timestamp: Date().addingTimeInterval(-1800),
//            location: PlateLocation(
//                geopoint: GeoPoint(latitude: 39.95, longitude: -75.16),
//                geohash: "dr4e",
//                restaurantName: "Home Cooked"
//            ),
//            isPublic: true
//        ),
//        Post(
//            id: "2",
//            authorID: "yasseen_eats",
//            imageURL: "https://i.imgur.com/d3XMjOK.jpeg",
//            caption: "Yummy burger",
//            timestamp: Date().addingTimeInterval(-3600),
//            location: PlateLocation(
//                geopoint: GeoPoint(latitude: 39.95, longitude: -75.16),
//                geohash: "dr4e",
//                restaurantName: "Burger World"
//            ),
//            isPublic: true
//        ),
//        Post(
//            id: "3",
//            authorID: "pranav_bites",
//            imageURL: "https://i.imgur.com/YonPoxk.jpeg",
//            caption: "Look at my food",
//            timestamp: Date().addingTimeInterval(-10000),
//            location: PlateLocation(
//                geopoint: GeoPoint(latitude: 39.95, longitude: -75.16),
//                geohash: "dr4e",
//                restaurantName: "The Halal Shack"
//            ),
//            isPublic: true
//        )
//    ]
    
    @State private var userHasPostedToday: Bool = true

    var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Text("Plate!")
                            .font(.system(size: 28, weight: .black))
                            .foregroundColor(.white)

                        ForEach(viewModel.posts) { post in
                            FeedCardView(post: post, isLocked: !userHasPostedToday)
                        }
                        
                        Spacer().frame(height: 50)
                        
                        Button("Log Out") {
                            authVM.signOut()
                        }
                        
                        Spacer().frame(height: 50)
                    }
                }
        }
    }
}

struct FeedCardView: View {
    let post: Post
    let isLocked: Bool
    
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
                    
                    Text(post.timestamp)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
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
                .frame(width: UIScreen.main.bounds.width - 40, height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.location)
                                .font(.system(size: 20, weight: .semibold))
                            Text("Philadelphia, PA")
                                .font(.system(size: 14, weight: .medium))
                                .italic()
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
                        .clipShape(RoundedRectangle(cornerRadius: 30))
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
