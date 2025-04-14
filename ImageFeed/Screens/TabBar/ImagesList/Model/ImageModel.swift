//
//  ImageModel.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
