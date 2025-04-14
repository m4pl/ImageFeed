//
//  LikeResult.swift
//  ImageFeed
//
//  Created by mpplokhov on 15.04.2025.
//

struct LikeResult: Decodable {
    let photo: PhotoResult
    
    enum CodingKeys: String, CodingKey {
        case photo
    }
}
