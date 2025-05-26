//
//  LoginTabView.swift
//  StudQR
//
//  Created by Andrew Belik on 5/19/25.
//

import SwiftUI

struct LoginTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"
    @State private var isSettingsPresented = false

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible = false
    @State private var showSuccessMessage = false
    @State private var loginError: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                Image(systemName: showSuccessMessage ? "checkmark.shield.fill" : "lock.shield")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(showSuccessMessage ? .green : .blue)
                    .padding()

                Text(showSuccessMessage ? localized("login_success") : localized("login_title"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)

                if !authViewModel.isAuthenticated && !showSuccessMessage {
                    VStack(spacing: 20) {
                        TextField(localized("email_placeholder"), text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.secondaryText.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.primaryText)

                        HStack {
                            if isPasswordVisible {
                                TextField(localized("password_placeholder"), text: $password)
                                    .foregroundColor(.primaryText)
                                    .textContentType(.none)
                                    .autocorrectionDisabled(true)
                                    .autocapitalization(.none)
                            } else {
                                SecureField(localized("password_placeholder"), text: $password)
                                    .foregroundColor(.primaryText)
                            }

                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.secondaryText)
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondaryText.opacity(0.3), lineWidth: 1)
                        )

                        if let loginError = loginError {
                            Text(loginError)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }

                        Button(action: {
                            loginError = nil
                            authViewModel.login(email: email, password: password) { success in
                                if success {
                                    showSuccessMessage = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showSuccessMessage = false
                                    }
                                } else {
                                    loginError = localized("login_error")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text(localized("login_button"))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .background(
                Color.appBackground
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
    }

    func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    LoginTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager())
}
