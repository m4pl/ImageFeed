//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!

    func configure(with viewModel: ImageCellViewModel) {
        let likeImageName = viewModel.isLiked ? "like_button_on" : "like_button_off"
        dateLabel.text = viewModel.dateText
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)

        if let url = viewModel.imageURL {
            cellImage.kf.setImage(with: url)
        } else {
            cellImage.image = nil
        }
    }
}
