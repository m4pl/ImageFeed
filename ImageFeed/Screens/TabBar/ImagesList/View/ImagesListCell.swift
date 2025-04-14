//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import Kingfisher
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"

    @IBOutlet var placeholder: UIImageView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!

    private var imageDownloadTask: DownloadTask?

    var photoId: String?
    var isLiked: Bool? {
        didSet {
            guard let isLiked = isLiked else { return }
            let image =
                isLiked
                ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            likeButton.setImage(image, for: .normal)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloadTask?.cancel()
    }

    @IBAction func didTapLikeButton(_ sender: Any) {
        guard let id = photoId else { return }
        let isLike = !(isLiked ?? false)
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: id, isLike: isLike) { _ in
            UIBlockingProgressHUD.dismiss()
        }
    }

    func configure(with viewModel: ImageCellViewModel) {
        photoId = viewModel.id
        isLiked = viewModel.isLiked
        dateLabel.text = viewModel.dateText
        placeholder.isHidden = false
        cellImage.kf.indicatorType = .activity

        imageDownloadTask = cellImage.kf.setImage(with: viewModel.imageURL) { [weak self] result in

            guard let self else { return }

            switch result {
            case .success(let value):
                self.cellImage.image = value.image
                self.placeholder.isHidden = true
            case .failure:
                break
            }
        }
    }
}
