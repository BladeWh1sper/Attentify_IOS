//
//  ContentView.swift
//  StudQR
//
//  Created by Andrew Belik on 29.03.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("selectedLanguage") private var selectedLanguage = "ru"

    var body: some View {
        NavigationStack {
            if authViewModel.isAuthenticated {
                TabView {
                    MainPageView()
                        .environmentObject(authViewModel)
                        .tabItem {
                            Label(localized("main_tab"), systemImage: "house")
                        }
                    
                    QRCodeScannerView()
                        .environmentObject(authViewModel)
                        .tabItem {
                            Label(localized("scan_tab"), systemImage: "qrcode.viewfinder")
                        }
                    
                    ScheduleView()
                        .environmentObject(authViewModel)
                        .tabItem {
                            Label(localized("schedule_tab"), systemImage: "calendar")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label(localized("profile_tab"), systemImage: "person.crop.circle")
                        }
                }
            } else {
                LoginTabView()
                    .environmentObject(authViewModel)
                    .tabItem {
                        Label(localized("login_tab"), systemImage: "person")
                    }
            }
        }
        .environmentObject(authViewModel)
    }

    func localized(_ key: String) -> String {
        let languageCode = selectedLanguage == "en" ? "en" : "ru"
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") ?? ""
        let bundle = Bundle(path: path) ?? .main
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
