//
//  ImageCellViewModel.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import UIKit

struct ImageCellViewModel {
    let id: String
    let image: UIImage?
    let dateText: String
    let imageURL: URL?
    let size: CGSize
    var isLiked: Bool
}
