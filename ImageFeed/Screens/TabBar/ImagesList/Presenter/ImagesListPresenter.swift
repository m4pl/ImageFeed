//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import Foundation
import UIKit

final class ImagesListPresenter {
    
    private weak var view: ImagesListView?
    private let service = ImagesListService.shared
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(view: ImagesListView) {
        self.view = view
        observePhotoUpdates()
        service.fetchPhotosNextPage()
    }
    
    private func observePhotoUpdates() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let userInfo = notification.userInfo,
               let value = userInfo["indexPaths"] as? [IndexPath] {
                self?.view?.updateImages(indexPaths: value)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didUpdateNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let userInfo = notification.userInfo,
               let value = userInfo["index"] as? [IndexPath] {
                self?.view?.reloadImages(indexPaths: value)
            }
        }
    }
    
    var imagesCount: Int {
        service.photos.count
    }
    
    func viewModel(for index: Int) -> ImageCellViewModel {
        let photo = service.photos[index]
        
        return ImageCellViewModel(
            id: photo.id,
            image: nil,
            dateText: formattedDate(photo.createdAt),
            imageURL: URL(string: photo.thumbImageURL),
            size: photo.size,
            isLiked: photo.isLiked
        )
    }
    
    func image(at index: Int) -> URL? {
        let photo = service.photos[index]
        return URL(string: photo.largeImageURL)
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        return dateFormatter.string(from: date)
    }
}
