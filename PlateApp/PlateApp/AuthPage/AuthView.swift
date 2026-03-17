//
//  AuthView.swift
//  PlateApp
//
//  Created by Yasseen Rouni on 3/11/26.
//

import SwiftUI


struct AuthView: View {
    @State var phoneNumber: String = ""
    @State var y: CGFloat = 150
    @State var countryCode = ""
    @State var countryFlag = ""
    @State var showPicker = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Log in with Phone Number")
                .font(.title)
                .bold()
            HStack(spacing: 0) {
                Text(countryCode.isEmpty ? "🇺🇸 +1" : "\(countryFlag) +\(countryCode)")
                    .frame(width: 80, height: 50)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(countryCode.isEmpty ? .secondary : .black)
                    .onTapGesture {
                        withAnimation (.spring()) {
                            showPicker.toggle()
                        }
                    }
                
                TextField("111 111-1111", text: $phoneNumber)
                    .padding()
                    .keyboardType(.phonePad)
            }
            .frame(width: 250, height: 50)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke())
            
            
            .sheet(isPresented: $showPicker) {
                CountryCodeView(countryCode: $countryCode, countryFlag: $countryFlag, y: $y)
                    .presentationDetents([.medium, .large])
            }
            
            Button("Continue") {
                // Action to perform when the button is tapped
                print("Continue button tapped!")
            }
        
        }
    }
}

struct CountryCodeView: View {
    @Binding var countryCode : String
    @Binding var countryFlag : String
    @Binding var y : CGFloat
    @Environment(\.dismiss) var dismiss
    var model = AuthModel()

    var body: some View {
        NavigationView {
            List(model.countryDictionary.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack {
                    Text("\(model.flag(country: key))")
                    Text("\(model.countryName(countryCode: key) ?? key)")
                    Spacer()
                    Text("+\(value)").foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .background(Color.white)
                .font(.system(size: 20))
                .onTapGesture {
                    self.countryCode = value
                    self.countryFlag = model.flag(country: key)
                    dismiss()
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}


#Preview {
    AuthView()
}
