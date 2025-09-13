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
                Color.appBackground.ignoresSafeArea()

                if let profile = authViewModel.profile {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Spacer()
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gear")
                                        .foregroundColor(.accentColor)
                                }
                            }

                            ProfileHeader(
                                initials: makeInitials(profile),
                                tint: .blue
                            )

                            VStack(spacing: 8) {
                                InfoRow(
                                    title: localized("name"),
                                    value: authViewModel.localized(profile.profile.first_name)
                                           + " "
                                           + authViewModel.localized(profile.profile.last_name)
                                )
                                InfoRow(title: "Email", value: profile.email)
                                InfoRow(
                                    title: localized("phone"),
                                    value: profile.profile.phone ?? "—"
                                )
                                InfoRow(
                                    title: localized("role"),
                                    value: authViewModel.localized(profile.role.name)
                                )
                            }

                            if !profile.groups.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(localized("groups"))
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
                                    ForEach(profile.groups, id: \.id) { group in
                                        Text("• " + authViewModel.localized(group.name))
                                            .foregroundColor(.secondaryText)
                                    }
                                }
                                .padding(.top, 8)
                            }

                            Button(action: { authViewModel.logout() }) {
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
                            .padding(.top, 16)
                        }
                        .padding()
                    }
                } else {
                    VStack {
                        Spacer()
                        Text(localized("profile_loading"))
                            .foregroundColor(.secondaryText)
                            .font(.headline)
                        Spacer()
                        Button(action: { authViewModel.logout() }) {
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
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    private func makeInitials(_ profile: ProfileResponse) -> String {
        let first = authViewModel.localized(profile.profile.first_name)
        let last  = authViewModel.localized(profile.profile.last_name)
        let fi = first.first.map(String.init) ?? ""
        let li = last.first.map(String.init) ?? ""
        return (fi + li).uppercased()
    }
}

#Preview {
    // Превью без сети: моковая VM и данные
    let vm = AuthViewModel(api: MockAuthNetworking())
    vm.isAuthenticated = true
    vm.profile = ProfileResponse(
        id: 1,
        email: "demo@example.com",
        is_superuser: false,
        profile: ProfileInfo(
            id: 1,
            first_name: LocalizedField(ru: "Иван", en: "Ivan"),
            last_name:  LocalizedField(ru: "Иванов", en: "Ivanov"),
            patronymic: LocalizedField(ru: "Иванович", en: "Ivanovich"),
            phone: "+7 000 000-00-00"
        ),
        role: Role(
            id: 1,
            name: LocalizedField(ru: "Студент", en: "Student"),
            description: LocalizedFieldOptional(ru: nil, en: nil)
        ),
        groups: [
            Group(id: 10, name: LocalizedField(ru: "ИБ-201", en: "IB-201"),
                  description: LocalizedFieldOptional(ru: nil, en: nil))
        ]
    )
    return ProfileView()
        .environmentObject(vm)
        .environmentObject(ThemeManager())
}
