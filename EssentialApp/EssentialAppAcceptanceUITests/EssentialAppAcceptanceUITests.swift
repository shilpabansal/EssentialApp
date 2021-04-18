//
//  EssentialAppAcceptanceUITests.swift
//  EssentialAppAcceptanceUITests
//
//  Created by Shilpa Bansal on 18/04/21.
//

import XCTest

class EssentialAppAcceptanceUITests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launch()

        let feedCells = app.cells.matching(identifier: "feed-cell")
        XCTAssertEqual(feedCells.count,22)

        let firstImage = app.cells.images.matching(identifier: "feed-image").firstMatch
        XCTAssertTrue(firstImage.exists)
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let app = XCUIApplication()
        app.launch()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launchArguments.append("test")
        offlineApp.launchArguments.append("connectivity")
        offlineApp.launch()
        
        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-cell")
        XCTAssertEqual(cachedFeedCells.count, 22)

        let firstCachedImage = app.cells.images.matching(identifier: "feed-image").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let app = XCUIApplication()
        app.launchArguments = ["reset", "-connectivity", "offline"]
        app.launch()

        let feedCells = app.cells.matching(identifier: "feed-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}
