//
//  WebViewTests.swift
//  WebViewTests
//
//  Created by mpplokhov on 15.04.2025.
//

import XCTest
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {}
    func code(from url: URL) -> String? { return nil }
    func shouldHideProgress(for value: Float) -> Bool { return false }
}

final class WebViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        vc.presenter = presenter
        presenter.view = vc

        _ = vc.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testProgressVisibleWhenLessThanOne() {
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        XCTAssertFalse(presenter.shouldHideProgress(for: 0.5))
    }

    func testProgressHiddenWhenOne() {
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        XCTAssertTrue(presenter.shouldHideProgress(for: 1.0))
    }

    func testAuthHelperAuthURL() {
        let helper = AuthHelper()
        let url = helper.authURL()?.absoluteString ?? ""

        XCTAssertTrue(url.contains("client_id"))
        XCTAssertTrue(url.contains("redirect_uri"))
        XCTAssertTrue(url.contains("response_type=code"))
        XCTAssertTrue(url.contains("scope"))
    }

    func testCodeFromURL() {
        var components = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        components.queryItems = [URLQueryItem(name: "code", value: "test-code")]
        let url = components.url!

        let code = AuthHelper().code(from: url)

        XCTAssertEqual(code, "test-code")
    }
}
