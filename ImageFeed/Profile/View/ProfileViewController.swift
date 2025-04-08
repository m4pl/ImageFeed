//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by mpplokhov on 08.04.2025.
//

import UIKit

final class ProfileViewController: UIViewController {

    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        print("Logout tapped")
    }

    private func setupUI() {
        avatarImageView.image = UIImage(named: "avatar")
        nameLabel.text = "Екатерина Новикова"
        loginNameLabel.text = "@ekaterina_nov"
        descriptionLabel.text = "Hello, World!"
    }
}
