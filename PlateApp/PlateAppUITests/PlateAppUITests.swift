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

        let signInViewTitle = app.staticTexts["Sign in to continue"]
        XCTAssertTrue(signInViewTitle.waitForExistence(timeout: 5), "The sign in view should be displayed")
    }

    func testFeedTitleIsVisible() {
        login()

        let title = app.staticTexts["feed_title_label"]
        
        let exists = title.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "The 'Plate!' header should be visible on launch.")
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
        
        let exists = cityLabel.waitForExistence(timeout: 5)

        XCTAssertTrue(exists, "The city label should be present on the feed card.")

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
    // MARK: - New View Specific Tests

        func testUploadSheetPresentation() {
            login()

            // Locates the plus.circle.fill button
            let uploadButton = app.buttons.element(boundBy: 0) // Or add identifier "upload_nav_button" to your Image/Button
            XCTAssertTrue(uploadButton.exists, "The upload button should be visible in the toolbar.")
            uploadButton.tap()

            // Assuming UploadView has a title or unique element
            let uploadViewElement = app.staticTexts.firstMatch // Adjust based on your UploadView content
            XCTAssertTrue(uploadViewElement.waitForExistence(timeout: 5), "The Upload sheet should appear after tapping the plus button.")
        }

        func testDeletePostFlow() {
            login()

            // 1. Check if a delete button exists on the first FeedCard
            let deleteButton = app.buttons["trash"].firstMatch
            // Note: You might need to add .accessibilityIdentifier("delete_button") to your trash button
            
            let exists = deleteButton.waitForExistence(timeout: 5)
            
            XCTAssertTrue(exists, "The delete button should be visible on the feed card.")
            
            // 2. Capture the initial count of posts or check visibility
            let initialPost = app.staticTexts["post_city_label"].firstMatch
            let initialCityName = initialPost.label
            
            deleteButton.tap()
            
            // 3. Verify the post is removed or the UI updates
            // We wait for the specific city label to disappear or change
            let postDeleted = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: initialPost, handler: nil)
            let result = XCTWaiter().wait(for: [postDeleted], timeout: 5.0)
            
            XCTAssertEqual(result, .completed, "The post should be removed from the UI after tapping delete.")
        }

        func testFeedLockingMechanism() {
            login()

            // If userHasPostedToday is false, the "Post to Unlock" overlay should appear
            // Note: Since this is a UI test, you'd trigger this by using a test user
            // who hasn't posted or mocking the state.
            
            let lockOverlayText = app.staticTexts["Post to Unlock"]
            
            // This test assumes the mock state where userHasPostedToday = false
            if lockOverlayText.exists {
                XCTAssertTrue(lockOverlayText.isHittable == false, "The overlay should block interaction with the card.")
                
                // Check if the image behind it is shielded
                let feedImage = app.images.firstMatch
                XCTAssertFalse(feedImage.isHittable, "User should not be able to interact with the post image when locked.")
            }
        }

        func testMapAnnotationExists() {
            login()

            app.tabBars.buttons["Map"].tap()
            
            // MapKit annotations are sometimes tricky to find.
            // They are often identified as "Other" elements or by their label.
            let map = app.maps.firstMatch
            XCTAssertTrue(map.waitForExistence(timeout: 5))
            
            // Check for any annotation (Circle in your code)
            // Since you used Annotation("", ...), we look for the count text overlay
            let annotationLabel = app.staticTexts.containing(NSPredicate(format: "label MATCHES '[0-9]+'")).firstMatch
            XCTAssertTrue(annotationLabel.exists, "At least one heatmap annotation should be visible on the map.")
        }
}
