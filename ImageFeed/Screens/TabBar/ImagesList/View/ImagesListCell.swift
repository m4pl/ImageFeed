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

    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    private var imageDownloadTask: DownloadTask?
    private var animationLayer: CAGradientLayer?
    
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
        removeAllGradientAnimations()
    }
    
    private func showLoadingAnimation() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor.lightGray.cgColor,
            UIColor.darkGray.cgColor,
            UIColor.lightGray.cgColor
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
        showLoadingAnimation()
        
        imageDownloadTask = cellImage.kf.setImage(with: viewModel.imageURL) { [weak self] result in
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
}
