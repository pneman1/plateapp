//
//  UploadView.swift
//  PlateApp
//
//  Created by Ryan Windle on 4/7/26.
//
import SwiftUI
import UIKit


struct UploadView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?

    var body: some View {
        VStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(20)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(Text("No Photo Taken").foregroundColor(.gray))
            }

            Button(action: {
                showCamera = true
            }) {
                Label("Snap a Plate", systemImage: "camera.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $capturedImage)
        }
    }
}

#Preview {
    UploadView()
}
