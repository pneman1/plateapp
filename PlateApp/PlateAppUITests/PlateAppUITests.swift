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
        app.launch()
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    @MainActor
    func testSignInButton() throws {
        let signInButton = app.buttons["signInLink"]
        XCTAssertTrue(signInButton.exists, "The signInButton button should exist")
        signInButton.tap()

        let signInViewTitle = app.staticTexts["Sign in with Email"]
        XCTAssertTrue(signInViewTitle.waitForExistence(timeout: 5), "The sign in view should be displayed")
    }

    func testFeedTitleIsVisible() {
        login()

        let title = app.staticTexts["feed_title_label"]

        XCTAssertTrue(title.exists, "The 'Plate!' header should be visible on launch.")
    }

    func testProfilePageShowsLogoutButton() {
        login()

        app.tabBars.buttons["Profile"].tap()

        let logOutButton = app.buttons["profileLogOutButton"]
        XCTAssertTrue(logOutButton.waitForExistence(timeout: 5), "The profile logout button should exist")
    }

    func testLogOutFlow() {
        login()

        app.tabBars.buttons["Profile"].tap()

        let logOutButton = app.buttons["profileLogOutButton"]
        XCTAssertTrue(logOutButton.waitForExistence(timeout: 5), "The profile logout button should exist")

        if logOutButton.isHittable {
            logOutButton.tap()
        } else {
            logOutButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }

        let signInButton = app.buttons["signInLink"]

        XCTAssertTrue(signInButton.waitForExistence(timeout: 5), "After logging out, the sign in button should be visible.")
    }

    func testMapPageShowsHeatmap() {
        login()

        app.tabBars.buttons["Map"].tap()

        let mapTitle = app.staticTexts["mapTitle"]
        XCTAssertTrue(mapTitle.waitForExistence(timeout: 5), "The map screen should be displayed")
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
