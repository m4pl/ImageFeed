//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 12.04.2025.
//

import SwiftKeychainWrapper

final class Oauth2TokenStorage {
    static let shared = Oauth2TokenStorage()

    private init() {}

    private let tokenKey = "OAuth2TokenKey"

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newToken = newValue {
                KeychainWrapper.standard.set(newToken, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
