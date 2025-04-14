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
    
    @IBOutlet var placeholder: UIImageView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    private var imageDownloadTask: DownloadTask?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloadTask?.cancel()
    }
    
    func configure(with viewModel: ImageCellViewModel) {
        let likeImageName = viewModel.isLiked ? "like_button_on" : "like_button_off"
        dateLabel.text = viewModel.dateText
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
        placeholder.isHidden = false
        cellImage.kf.indicatorType = .activity

        imageDownloadTask = cellImage.kf.setImage(with: viewModel.imageURL) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let value):
                self.cellImage.image = value.image
                self.placeholder.isHidden = true
                
                if let tableView = self.superview as? UITableView,
                   let indexPath = tableView.indexPath(for: self) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure:
                break
            }
        }
    }
}
