//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    func configure(with viewModel: ImageCellViewModel) {
        let likeImageName = viewModel.isLiked ? "like_button_on" : "like_button_off"
        cellImage.image = viewModel.image
        dateLabel.text = viewModel.dateText
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}
