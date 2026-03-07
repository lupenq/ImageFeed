import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "OAuthToken")
        }
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: "OAuthToken")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "OAuthToken")
            }
        }
    }
}
