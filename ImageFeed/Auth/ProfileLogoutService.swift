//
//  ProfileLogoutService.swift
//  ImageFeed
//

import Foundation
import WebKit
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
        cleanCookies()
        switchToSplashScreen()
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
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            window.rootViewController = SplashViewController()
        }
    }
}
