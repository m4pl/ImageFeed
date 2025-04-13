//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by mpplokhov on 08.04.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    var avatarImage: UIImage? {
        didSet {
            avatarImageView.image = avatarImage
        }
    }

    var nameText: String = "" {
        didSet {
            nameLabel.text = nameText
        }
    }

    var loginText: String = "" {
        didSet {
            loginNameLabel.text = loginText
        }
    }

    var descriptionText: String? = "" {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar_placeholder"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.addTarget(
            nil,
            action: #selector(logoutButtonTapped),
            for: .touchUpInside
        )
        return button
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.YPGray
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()

    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfileDetails()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.YPBlack

        [
            avatarImageView,
            logoutButton,
            nameLabel,
            loginNameLabel,
            descriptionLabel,
        ].forEach {
            view.addSubview($0)
        }

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 32
            ),
            avatarImageView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            avatarImageView.widthAnchor.constraint(
                equalToConstant: 70
            ),
            avatarImageView.heightAnchor.constraint(
                equalToConstant: 70
            ),

            logoutButton.centerYAnchor.constraint(
                equalTo: avatarImageView.centerYAnchor
            ),
            logoutButton.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -16
            ),
            logoutButton.widthAnchor.constraint(
                equalToConstant: 44
            ),
            logoutButton.heightAnchor.constraint(
                equalToConstant: 44
            ),

            nameLabel.topAnchor.constraint(
                equalTo: avatarImageView.bottomAnchor,
                constant: 8
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            nameLabel.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -16
            ),

            loginNameLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 8
            ),
            loginNameLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            loginNameLabel.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -16
            ),

            descriptionLabel.topAnchor.constraint(
                equalTo: loginNameLabel.bottomAnchor,
                constant: 8
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -16
            ),
        ])
    }

    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else { return }

        nameText = profile.name
        loginText = profile.loginName
        descriptionText = profile.bio
        updateAvatar()

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateAvatar()
        }
    }

    private func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURL)
        else { return }
        
        avatarImageView.kf.setImage(with: url)
    }

    @objc private func logoutButtonTapped(_ sender: UIButton) {
        print("Logout tapped")
    }
}
