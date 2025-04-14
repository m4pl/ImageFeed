//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by mpplokhov on 14.04.2025.
//

import CoreGraphics
import UIKit

final class ImagesListService {
    static let shared = ImagesListService()

    private init() {}

    private(set) var photos: [Photo] = []
    private var fetchPhotosTask: URLSessionTask?
    private var changeLikeTask: URLSessionTask?
    private var lastLoadedPage: Int?
    static let didChangeNotification = Notification.Name(
        "ImagesListServiceDidChange"
    )
    static let didUpdateNotification = Notification.Name("ImageDidUpdate")

    private let perPage = 10

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard fetchPhotosTask == nil else { return }

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makeImagesListRequest(nextPage: nextPage) else {
            return
        }

        fetchPhotosTask = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }

            self.fetchPhotosTask = nil

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

        fetchPhotosTask?.resume()
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard changeLikeTask == nil else { return }

        guard
            let request = makeChangeLikeRequest(
                photoId: photoId,
                isLike: isLike
            )
        else {
            print("Error: Failed to create URLRequest from photo: \(photoId)")
            return
        }

        changeLikeTask = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<LikeResult, Error>) in
            guard let self = self else { return }
            self.changeLikeTask = nil

            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    guard
                        let index = self.photos.firstIndex(where: {
                            $0.id == photoId
                        })
                    else { return }

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

        changeLikeTask?.resume()
    }

    func reset() {
        self.photos = []
        self.fetchPhotosTask = nil
        self.changeLikeTask = nil
        self.lastLoadedPage = nil
    }

    private func makeImagesListRequest(nextPage: Int) -> URLRequest? {
        guard let token = Oauth2TokenStorage.shared.token else {
            return nil
        }

        var urlComponents = URLComponents(
            string: "https://api.unsplash.com/photos"
        )!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: String(perPage)),
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        return request
    }

    private func makeChangeLikeRequest(photoId: String, isLike: Bool)
        -> URLRequest?
    {
        guard let token = Oauth2TokenStorage.shared.token else {
            return nil
        }

        let urlComponents = URLComponents(
            string: "https://api.unsplash.com/photos/\(photoId)/like"
        )!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}

extension PhotoResult {
    
    private static let dateFormatter: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()

    func toPhoto() -> Photo {
        let size = CGSize(width: width, height: height)
        let createdAt = Self.dateFormatter.date(from: createdAt ?? "")

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
