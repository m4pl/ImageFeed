//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by mpplokhov on 14.04.2025.
//

import Foundation
import WebKit
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
  
    private init() { }

    func logout() {
        cleanCookies()
        clearToken()
        clearProfile()
        clearAvatar()
        clearImages()
        switchToSplashScreen()
    }

    private func clearToken() {
        Oauth2TokenStorage.shared.clearToken()
    }

    private func clearProfile() {
        ProfileService.shared.reset()
    }

    private func clearAvatar() {
        ProfileImageService.shared.reset()
    }

    private func clearImages() {
        ImagesListService.shared.reset()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }
}
