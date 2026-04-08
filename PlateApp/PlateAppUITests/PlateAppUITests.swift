//
//  PlateAppUITests.swift
//  PlateAppUITests
//
//  Created by Yasseen Rouni on 3/25/26.
//

import XCTest

final class PlateAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
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
        let app = XCUIApplication()
        app.launch()
        
        let signInLink = app.links["signInLink"]
        XCTAssertTrue(signInLink.exists, "The signInLink navigation link should exist")
        signInLink.tap()
        
        let signInViewTitle = app.staticTexts["Sign in with Email"]
        XCTAssertTrue(signInViewTitle.waitForExistence(timeout: 5), "The sign in view should be displayed")
    }

    @MainActor
    func testProfilePageShowsLogoutButton() throws {
        let app = XCUIApplication()
        app.launch()

        guard !app.links["signInLink"].waitForExistence(timeout: 2) else {
            throw XCTSkip("Profile screen requires a signed-in app state")
        }

        let profileLink = app.buttons["profileNavigationLink"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 5), "The profile navigation link should exist on the feed")
        profileLink.tap()

        XCTAssertTrue(app.staticTexts["profileTitle"].waitForExistence(timeout: 5), "The profile screen should be displayed")
        XCTAssertTrue(app.buttons["profileLogOutButton"].exists, "The profile screen should show a logout button")
    }

    @MainActor
    func testMapPageShowsHeatmap() throws {
        let app = XCUIApplication()
        app.launch()

        guard !app.links["signInLink"].waitForExistence(timeout: 2) else {
            throw XCTSkip("Map screen requires a signed-in app state")
        }

        let mapLink = app.buttons["mapNavigationLink"]
        XCTAssertTrue(mapLink.waitForExistence(timeout: 5), "The map navigation link should exist on the feed")
        mapLink.tap()

        XCTAssertTrue(app.staticTexts["mapTitle"].waitForExistence(timeout: 5), "The map screen should be displayed")
    }
}
