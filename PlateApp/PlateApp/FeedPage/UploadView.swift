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
import FirebaseAuth

struct UploadView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentLocation: CLLocation?
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var caption: String = ""
    @State private var restaurantName: String = ""
    @State private var isUploading = false
    @State private var rating: Int = 5
    @State private var mealType: String = "Lunch"

    let mealOptions = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    @Environment(\.dismiss) var dismiss

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
                HStack {
                    Text("Rating:")
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .foregroundColor(index <= rating ? .yellow : .gray)
                                .onTapGesture {
                                    rating = index
                                }
                        }
                    }
                }
                .padding(.horizontal)

                Picker("Meal Type", selection: $mealType) {
                    ForEach(mealOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)
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
        .onAppear {
                LocationHelper.shared.requestLocation { location in
                    self.currentLocation = location
                }
            }
    }
    
    func createPost() {
        guard let image = capturedImage else { return }
        isUploading = true
        
        // Step A: Upload to Storage first
        StorageManager.shared.uploadPostImage(image: image) { result in
            switch result {
            case .success(let url):
                // Step B: Once we have the real URL, save to Firestore
                saveToFirestore(imageURL: url.absoluteString)
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
                isUploading = false
            }
        }
    }

    private func saveToFirestore(imageURL: String) {
        let lat = currentLocation?.coordinate.latitude ?? 39.98
        let lon = currentLocation?.coordinate.longitude ?? -75.15
        
        let db = Firestore.firestore()
        let newPost = Post(
            userID: Auth.auth().currentUser?.uid ?? "",
            username: authVM.user?.username ?? "",
            imageURL: imageURL,
            caption: caption,
            timestamp: Date(),
            location: PlateLocation(
                geopoint: GeoPoint(latitude: lat, longitude: lon),
                restaurantName: restaurantName
            ),
            rating: rating,
            mealType: mealType,
            isPublic: true
        )
        
        do {
            try db.collection("images").addDocument(from: newPost)
            isUploading = false
            dismiss()
        } catch {
            print("Firestore Error: \(error)")
            isUploading = false
        }
    }
}

#Preview {
    UploadView()
}
