//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by mpplokhov on 11.04.2025.
//

import UIKit
import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {

    private let webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "nav_back_button"), for: .normal)
        button.addTarget(
            nil,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()

    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAuthView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    private func setupUI() {
        view.backgroundColor = UIColor.white

        [
            webView,
            backButton,
            progressView,
        ].forEach {
            view.addSubview($0)
        }

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 9
            ),
            backButton.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 9
            ),
            backButton.widthAnchor.constraint(
                equalToConstant: 24
            ),
            backButton.heightAnchor.constraint(
                equalToConstant: 24
            ),

            webView.topAnchor.constraint(
                equalTo: backButton.bottomAnchor,
                constant: 9
            ),
            webView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            webView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            webView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            
            progressView.topAnchor.constraint(
                equalTo: webView.topAnchor
            ),
            progressView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            progressView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

        ])

        webView.navigationDelegate = self
    }

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        updateProgress()
    }

    @objc private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
