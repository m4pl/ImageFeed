//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by mpplokhov on 14.04.2025.
//

import Foundation
import CoreGraphics
import Foundation
import UIKit

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let regular: String
}


final class ImagesListService {
    static let shared = ImagesListService()
    
    private init() {}
    
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private let perPage = 10
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeImagesListRequest(nextPage: nextPage) else {
            print("Error: Failed to create URLRequest from page: \(nextPage)")
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            self.task = nil
            
            switch result {
            case .success(let photoResults):
                let newPhotos: [Photo] = photoResults.map { result in
                    let size = CGSize(width: result.width, height: result.height)
                    let createdAt = ISO8601DateFormatter().date(from: result.createdAt ?? "")
                    return Photo(
                        id: result.id,
                        size: size,
                        createdAt: createdAt,
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.regular,
                        isLiked: result.likedByUser
                    )
                }
                
                DispatchQueue.main.async {
                    let oldCount = self.photos.count
                    let newCount = oldCount + newPhotos.count
                    let indexPaths = (oldCount..<newCount).map {
                        IndexPath(row: $0, section: 0)
                    }

                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["indexPaths": indexPaths]
                    )
                }
                
            case .failure(let error):
                print("Error: Failed to fetch photos: \(error)")
            }
        }
        
        task?.resume()
    }
    
    private func makeImagesListRequest(nextPage: Int) -> URLRequest? {
        guard let token = Oauth2TokenStorage.shared.token else {
            return nil
        }

        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
}
