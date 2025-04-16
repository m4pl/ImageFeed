//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by mpplokhov on 15.04.2025.
//

import Foundation

enum Constants {
    static let accessKey = "IFMz261ctOpB2imkof0eSL0Bw2lmZqa7JtUpLbKcVmw"
    static let secretKey = "lXhp5CQ67lntlxdtgl-mFbOHFsHQ7zjEL28tbHg5a_0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            authURLString: Constants.unsplashAuthorizeURLString
        )
    }
}
