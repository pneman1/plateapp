//
//  OnboardingView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 4/29/26.
//
import SwiftUI
import AVFoundation
import Foundation

struct OnboardingView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentStep) {
                // Step 1: Value Prop
                OnboardingStepView(
                    title: "Share your Plate",
                    description: "Post your daily meal once a day to see what your friends are eating. No filters, just food.",
                    icon: "fork.knife.circle.fill",
                    tag: 0
                )
                .tag(0)
                
                // Step 3: Social
                OnboardingStepView(
                    title: "Find Your Circle",
                    description: "Plate is better with friends. Connect to see authentic meals your friends are eating.",
                    icon: "person.2.fill",
                    tag: 1,
                    isLastStep: true,
                    action: {
                        Task { await authVM.completeOnboarding() }
                    }
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

struct OnboardingStepView: View {
    let title: String
    let description: String
    let icon: String
    let tag: Int
    var isLastStep: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(Color(.primary))
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.largeTitle.bold())
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            if isLastStep {
                Button(action: { action?() }) {
                    Text("Enter Plate!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.primary))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .foregroundColor(.white)
    }
}
