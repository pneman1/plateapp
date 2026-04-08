//
//  MapView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    )

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                ForEach(viewModel.hotspots) { hotspot in
                    Annotation("", coordinate: hotspot.coordinate) {
                        Circle()
                            .fill(heatColor(for: hotspot.postCount).opacity(0.45))
                            .frame(
                                width: heatSize(for: hotspot.postCount),
                                height: heatSize(for: hotspot.postCount)
                            )
                            .overlay(
                                Text("\(hotspot.postCount)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .ignoresSafeArea()

            Text("Food Heatmap")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.65))
                .cornerRadius(8)
                .padding(.top, 20)
                .accessibilityIdentifier("mapTitle")
        }
    }

    private func heatSize(for count: Int) -> CGFloat {
        min(80, 28 + CGFloat(count * 10))
    }

    private func heatColor(for count: Int) -> Color {
        if count >= 5 {
            return .red
        } else if count >= 3 {
            return .orange
        } else {
            return .yellow
        }
    }
}

#Preview {
    MapView()
}
