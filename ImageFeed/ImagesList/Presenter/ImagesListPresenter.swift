//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import Foundation
import UIKit

protocol ImagesListView: AnyObject {
    func updateImages()
}

final class ImagesListPresenter {

    private weak var view: ImagesListView?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private(set) var images: [ImageModel] = []
    
    init(view: ImagesListView) {
        self.view = view
        loadImages()
    }

    private func loadImages() {
        images = (0..<20).map {
            ImageModel(
                imageName: "\($0)",
                date: Date(),
                isLiked: $0 % 2 == 0
            )
        }

        view?.updateImages()
    }

    func viewModel(for index: Int) -> ImageCellViewModel {
        let model = images[index]

        return ImageCellViewModel(
            image: UIImage(named: model.imageName),
            dateText: dateFormatter.string(from: model.date),
            isLiked: model.isLiked
        )
    }

    var imagesCount: Int {
        return images.count
    }
}
