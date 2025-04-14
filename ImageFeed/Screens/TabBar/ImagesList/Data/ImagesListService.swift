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

struct LikeResult: Decodable {
    let photo: PhotoResult
    
    enum CodingKeys: String, CodingKey {
        case photo
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
    private var fetchPhotos: URLSessionTask?
    private var changeLike: URLSessionTask?
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let didUpdateNotification = Notification.Name("ImageDidUpdate")
    
    private let perPage = 10
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard fetchPhotos == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeImagesListRequest(nextPage: nextPage) else {
            print("Error: Failed to create URLRequest from page: \(nextPage)")
            return
        }
        
        fetchPhotos = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            self.fetchPhotos = nil
            
            switch result {
            case .success(let photoResults):
                let newPhotos: [Photo] = photoResults.map { result in
                    return result.toPhoto()
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
        
        fetchPhotos?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard changeLike == nil else { return }
        
        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("Error: Failed to create URLRequest from photo: \(photoId)")
            return
        }

        changeLike = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self = self else { return }
            self.changeLike = nil
            
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else { return }
                    
                    self.photos[index] = result.photo.toPhoto()
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didUpdateNotification,
                        object: self,
                        userInfo: ["index": [IndexPath(row: index, section: 0)]]
                    )
                    
                    completion(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        changeLike?.resume()
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
    
    private func makeChangeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = Oauth2TokenStorage.shared.token else {
            return nil
        }
        
        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos/\(photoId)/like")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

extension PhotoResult {
    func toPhoto() -> Photo {
        let size = CGSize(width: width, height: height)
        let createdAt = ISO8601DateFormatter().date(from: createdAt ?? "")
        
        return Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: description,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.regular,
            isLiked: likedByUser
        )
    }
}
