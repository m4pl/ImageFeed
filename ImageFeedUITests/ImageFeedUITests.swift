//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by mpplokhov on 15.04.2025.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        webView.swipeUp()
        
        passwordTextField.tap()
        passwordTextField.typeText("<Ваш пароль>")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        firstCell.swipeUp()
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["like_button_off"].tap()
        cellToLike.buttons["like_button_on"].tap()
        
        sleep(2)
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        app.buttons["Back"].tap()
    }
    
    func testProfile() throws {
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        
        let nameLabel = app.staticTexts["ProfileName"]
        let loginLabel = app.staticTexts["ProfileLogin"]
        
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(loginLabel.exists)
        
        app.buttons["Logout"].tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        alert.buttons["Да"].tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
