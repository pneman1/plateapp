//
//  UploadView.swift
//  PlateApp
//
//  Created by Ryan Windle on 4/7/26.
//
import SwiftUI
import UIKit
import FirebaseStorage
import FirebaseFirestore
import CoreLocation
import Foundation

struct UploadView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var caption: String = ""
    @State private var restaurantName: String = ""
    @State private var isUploading = false
    
    @Environment(\.dismiss) var dismiss // To close the sheet after posting

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Button(action: { showCamera = true }) {
                        VStack {
                            Image(systemName: "camera.fill").font(.largeTitle)
                            Text("Tap to take a photo")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    }
                }

                TextField("Restaurant Name", text: $restaurantName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                TextField("Write a caption...", text: $caption)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if isUploading {
                    ProgressView("Uploading to the Feed...")
                } else {
                    Button("Post Plate!") {
                        createPost()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(capturedImage == nil || restaurantName.isEmpty)
                }
                
                Spacer()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $capturedImage)
            }
        }
    }
    
    func createPost() {
        isUploading = true
        
        // In a real app, we'd upload the UIImage to Firebase Storage first
        // and get back a URL. For this step, we use a placeholder:
        let mockImageURL = "https://i.imgur.com/RpzNeWO.jpeg"
        
        let newPost = Post(
            userID: "ryan_dev_test", // Use your authVM.currentUser.id here later
            imageURL: mockImageURL,
            caption: caption,
            timestamp: Date(),
            location: PlateLocation(
                geopoint: GeoPoint(latitude: 39.98, longitude: -75.15), // Temple University
                geohash: "dr4e",
                restaurantName: restaurantName
            ),
            isPublic: true
        )
        
        // Send to Firestore
        let db = Firestore.firestore()
        do {
            try db.collection("images").addDocument(from: newPost)
            isUploading = false
            dismiss() // Close the upload screen
        } catch {
            print("Error uploading: \(error)")
            isUploading = false
        }
    }
}

#Preview {
    UploadView()
}
