//
//  ProfileView.swift
//  StudQR
//
//  Created by Andrew Belik on 5/19/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if let profile = authViewModel.profile {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                            Spacer()
                        }

                        SwiftUI.Group {
                            Text("\(localized("name")): \(getLocalized(profile.profile.first_name)) \(getLocalized(profile.profile.last_name))")
                            Text("Email: \(profile.email)")
                            Text("\(localized("phone")): \(profile.profile.phone ?? "—")")
                            Text("\(localized("role")): \(getLocalized(profile.role.name))")
                        }
                        .foregroundColor(Color.primaryText)
                        .font(.body)

                        if !profile.groups.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(localized("groups"))
                                    .font(.headline)
                                    .foregroundColor(Color.primaryText)

                                ForEach(profile.groups, id: \.id) { group in
                                    Text("• \(getLocalized(group.name))")
                                        .foregroundColor(Color.secondaryText)
                                }
                            }
                            .padding(.top, 8)
                        }

                        Spacer()

                        Button(action: {
                            authViewModel.logout()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text(localized("logout"))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                } else {
                    VStack {
                        Spacer()
                        Text(localized("profile_loading"))
                            .foregroundColor(Color.secondaryText)
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            authViewModel.logout()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text(localized("logout"))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(localized("profile_title"))
        }
    }

    func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    func getLocalized(_ field: LocalizedField) -> String {
        return selectedLanguage == "en" ? field.en : field.ru
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
