//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 12.04.2025.
//

import Foundation

class OAuth2TokenStorage {
    
    private let tokenKey = "OAuth2TokenKey"
    private let defaults = UserDefaults.standard

    var token: String? {
        get {
            return defaults.string(forKey: tokenKey)
        }
        set {
            if let newToken = newValue {
                defaults.set(newToken, forKey: tokenKey)
            } else {
                defaults.removeObject(forKey: tokenKey)
            }
        }
    }

    func clearToken() {
        defaults.removeObject(forKey: tokenKey)
    }
}
