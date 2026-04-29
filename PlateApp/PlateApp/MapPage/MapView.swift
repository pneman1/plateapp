//
//  MapView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import Kingfisher
import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var selectedCluster: MapPhotoCluster?

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                ForEach(viewModel.clusters) { cluster in
                    Annotation(cluster.title, coordinate: cluster.coordinate) {
                        MapPhotoCardAnnotation(cluster: cluster) {
                            selectedCluster = cluster
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            Text("Photo Map")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.65))
                .cornerRadius(8)
                .padding(.top, 20)
                .accessibilityIdentifier("mapTitle")
        }
        .sheet(item: $selectedCluster) { cluster in
            MapClusterSheet(cluster: cluster)
                .presentationDetents([.fraction(0.3), .medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct MapPhotoCardAnnotation: View {
    let cluster: MapPhotoCluster
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    if cluster.postCount > 1 {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.black.opacity(0.22))
                            .frame(width: 74, height: 92)
                            .offset(x: -6, y: 6)

                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.black.opacity(0.32))
                            .frame(width: 74, height: 92)
                            .offset(x: -3, y: 3)
                    }

                    cardContent
                }

                if cluster.postCount > 1 {
                    Text("\(cluster.postCount)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.85))
                        .clipShape(Capsule())
                        .offset(x: 10, y: -10)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var cardContent: some View {
        if let imageURL = cluster.coverPost?.imageURL, let url = URL(string: imageURL) {
            KFImage(url)
                .placeholder {
                    placeholder
                }
                .retry(maxCount: 2, interval: .seconds(1))
                .cacheOriginalImage()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 78, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [.black.opacity(0.78), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cluster.coverPost?.location.restaurantName ?? "Plate!")
                                .font(.system(size: 10, weight: .bold))
                                .lineLimit(1)

                            Text(cluster.coverPost?.username ?? "")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        .foregroundStyle(.white)
                        .padding(8)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.9), lineWidth: 2)
                }
                .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
        } else {
            placeholder
                .frame(width: 78, height: 96)
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.9), lineWidth: 2)
                }
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                LinearGradient(
                    colors: [Color.orange.opacity(0.9), Color.red.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
    }
}

private struct MapClusterSheet: View {
    let cluster: MapPhotoCluster

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(cluster.postCount == 1 ? "1 post here" : "\(cluster.postCount) posts here")
                        .font(.system(size: 24, weight: .black))

                    ForEach(cluster.posts) { post in
                        MapClusterPostCard(post: post)
                    }
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(cluster.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct MapClusterPostCard: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            KFImage(URL(string: post.imageURL))
                .placeholder {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                        .overlay(ProgressView().tint(.white))
                }
                .retry(maxCount: 2, interval: .seconds(1))
                .cacheOriginalImage()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.location.restaurantName)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(post.username)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))

                    if !post.caption.isEmpty {
                        Text(post.caption)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(post.dateString)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.72))

                    Label("\(post.rating)", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    MapView()
}
