//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 13.04.2025.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private let decoder = JSONDecoder()

    private init() {}

    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastUsername: String?

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard lastUsername != username else { return }
        task?.cancel()
        lastUsername = username

        guard let request = makeUserRequest(username: username) else {
            print("Error: Failed to create URLRequest from username: \(username)")
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        task = URLSession.shared.objectTask(for: request) {  [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                let profileImageURL = response.profileImage.small

                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }

        task?.resume()
    }
    
    private func makeUserRequest(username: String) -> URLRequest? {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/users/\(username)")!)

        guard let token = Oauth2TokenStorage.shared.token else {
            return nil
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
