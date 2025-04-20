//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by mpplokhov on 11.04.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "auth_screen_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.setTitle(NSLocalizedString("Войти", comment: ""), for: .normal)
        button.setTitleColor(UIColor.YPBlack, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = UIColor.white
        button.addTarget(
            nil,
            action: #selector(loginButtonTapped),
            for: .touchUpInside
        )
        button.accessibilityIdentifier = "Authenticate"
        return button
    }()

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.YPBlack

        [
            logoImageView,
            loginButton,
        ].forEach {
            view.addSubview($0)
        }

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            logoImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            logoImageView.widthAnchor.constraint(
                equalToConstant: 60
            ),
            logoImageView.heightAnchor.constraint(
                equalToConstant: 60
            ),

            loginButton.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 16
            ),
            loginButton.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -16
            ),
            loginButton.bottomAnchor.constraint(
                equalTo: safeArea.bottomAnchor,
                constant: -90
            ),
            loginButton.heightAnchor.constraint(
                equalToConstant: 48
            ),
        ])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(ShowWebViewSegueIdentifier)")
                return
            }
            let helper = AuthHelper()
            let presenter = WebViewPresenter(authHelper: helper)
            webViewViewController.presenter = presenter
            presenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func loginButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: ShowWebViewSegueIdentifier, sender: sender)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
