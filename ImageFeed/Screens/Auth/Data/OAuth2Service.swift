//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 12.04.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let decoder = JSONDecoder()

    private init() {}

    private var task: URLSessionTask?
    private var lastCode: String?

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard lastCode != code else { return }
        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error: Failed to create URLRequest from code: \(code)")
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.oauth2TokenStorage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    print("Error: Failed to decode OAuthTokenResponseBody: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Error: Network request failed: \(error)")
                completion(.failure(error))
            }
        }

        task?.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = urlComponents?.url else {
            print("Error: Invalid URL components for Unsplash OAuth token request")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
