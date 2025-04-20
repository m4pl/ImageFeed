//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by mpplokhov on 15.04.2025.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
    func authURL() -> URL?
}

final class AuthHelper: AuthHelperProtocol {

    private let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authURL() -> URL? {
        var components = URLComponents(string: configuration.authURLString)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope),
        ]
        return components?.url
    }
    
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        guard let components = URLComponents(string: url.absoluteString),
              components.path == "/oauth/authorize/native",
              let item = components.queryItems?.first(where: { $0.name == "code" })
        else { return nil }
        
        return item.value
    }
}
