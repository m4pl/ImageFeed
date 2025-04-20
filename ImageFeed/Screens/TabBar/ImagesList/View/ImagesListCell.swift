//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Matvei Plokhov on 06.04.2025.
//

import Kingfisher
import UIKit

final class ImagesListCell: UITableViewCell {

    // MARK: - Reuse ID

    static let reuseIdentifier = Constants.reuseIdentifier

    // MARK: - Outlets

    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Private Properties

    private var imageDownloadTask: DownloadTask?
    private var animationLayer: CAGradientLayer?

    // MARK: - Public Properties

    var photoId: String?

    var isLiked: Bool? {
        didSet {
            guard let isLiked else { return }
            let imageName =
                isLiked
                ? Constants.likeButtonOnImage : Constants.likeButtonOffImage
            likeButton.setImage(UIImage(named: imageName), for: .normal)
            likeButton.accessibilityIdentifier = imageName
        }
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloadTask?.cancel()
        removeAllGradientAnimations()
    }

    // MARK: - Configuration

    func configure(with viewModel: ImageCellViewModel) {
        photoId = viewModel.id
        isLiked = viewModel.isLiked
        dateLabel.text = viewModel.dateText
        showLoadingAnimation()

        imageDownloadTask = cellImage.kf.setImage(with: viewModel.imageURL) {
            [weak self] result in
            guard let self else { return }
            self.removeAllGradientAnimations()

            switch result {
            case .success(let value):
                self.cellImage.image = value.image
            case .failure:
                break
            }
        }
    }

    // MARK: - Actions

    @IBAction private func didTapLikeButton(_ sender: Any) {
        guard let id = photoId else { return }
        let isLike = !(isLiked ?? false)

        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: id, isLike: isLike) { _ in
            UIBlockingProgressHUD.dismiss()
        }
    }

    // MARK: - Loading Animation

    private func showLoadingAnimation() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor.lightGray.cgColor,
            UIColor.darkGray.cgColor,
            UIColor.lightGray.cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity

        gradient.add(animation, forKey: "shimmer")
        cellImage.layer.addSublayer(gradient)
        animationLayer = gradient
    }

    private func removeAllGradientAnimations() {
        animationLayer?.removeFromSuperlayer()
        animationLayer = nil
    }

    private enum Constants {
        static let reuseIdentifier = "ImagesListCell"
        static let likeButtonOnImage = "like_button_on"
        static let likeButtonOffImage = "like_button_off"
    }
}
