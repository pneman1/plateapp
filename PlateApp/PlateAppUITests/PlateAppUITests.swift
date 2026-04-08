//
//  PlateAppUITests.swift
//  PlateAppUITests
//
//  Created by Yasseen Rouni on 3/25/26.
//

import XCTest

final class PlateAppUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch() // This starts the app fresh for every test
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    @MainActor
    func testSignInButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        let signInButton = app.buttons["signInButton"]
        XCTAssertTrue(signInButton.exists, "The signInButton button should exist")
        signInButton.tap()
        
        let signInViewTitle = app.staticTexts["Sign in with Email"]
        XCTAssertTrue(signInViewTitle.waitForExistence(timeout: 5), "The sign in view should be displayed")
    }
    
    func testFeedTitleIsVisible() {
            // 1. Find the element by the ID we set earlier
            let title = app.staticTexts["feed_title_label"]
            
            // 2. Assert (Check) that it exists on the screen
            XCTAssertTrue(title.exists, "The 'Plate!' header should be visible on launch.")
        }

    func testLogOutFlow() {
        let logOutButton = app.buttons["log_out_button"]
        
        while !logOutButton.exists {
            app.swipeUp()
        }
        
        if logOutButton.isHittable {
            logOutButton.tap()
        } else {
            logOutButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        
        XCTAssertTrue(app.buttons["signInButton"].exists)
    }
    
    func testLocationResolution() {
        login()
        
        let cityLabel = app.staticTexts["post_city_label"].firstMatch
        
        XCTAssertTrue(cityLabel.exists, "The city label should be present on the feed card.")
        
        let notLoading = NSPredicate(format: "label != 'Loading...'")
        let expectation = expectation(for: notLoading, evaluatedWith: cityLabel, handler: nil)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
        
        XCTAssertEqual(result, .completed, "The location should resolve to a real city name within 10 seconds.")
        
        XCTAssertNotEqual(cityLabel.label, "Loading...")
        print("Resolved City: \(cityLabel.label)")
    }
    
    func login() {
        
        let signInButton = app.buttons["signInLink"]
        if signInButton.exists {
            signInButton.tap()
        }
        
        let emailField = app.textFields["email_tf"]
        let passwordField = app.secureTextFields["password_tf"]
        let loginButton = app.buttons["logInButton"]

        if loginButton.exists {
            emailField.tap()
            emailField.typeText("test@test.edu")
            
            passwordField.tap()
            passwordField.typeText("password123")
            
            loginButton.tap()
            
            let feedTitle = app.staticTexts["feed_title_label"]
            XCTAssertTrue(feedTitle.waitForExistence(timeout: 10), "Login failed or Feed didn't load.")
        }
    }
}
