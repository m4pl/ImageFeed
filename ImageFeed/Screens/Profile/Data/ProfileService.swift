//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 13.04.2025.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    static let shared = ProfileService()

    private init() {}

    private (set) var profile: Profile?
    private var task: URLSessionTask?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)

        task?.cancel()

        let request = makeProfileRequest(token: token)
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                let profile = Profile(
                    username: response.username,
                    name: "\(response.firstName) \(response.lastName)",
                    loginName: "@\(response.username)",
                    bio: response.bio
                )

                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        task?.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.unsplash.com/me")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

