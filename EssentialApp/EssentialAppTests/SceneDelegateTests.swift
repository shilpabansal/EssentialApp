//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 24/04/21.
//

import XCTest
@testable import EssentialApp
import EssentialFeed

class SceneDelegateTests: XCTestCase {
    func test_sceneWillConnectToSession_confifureRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()
        
        let root = sut.window?.rootViewController
        let rootNavigation = (root as? UINavigationController)
        
        let topViewController = rootNavigation?.topViewController
        XCTAssertNotNil(rootNavigation, "Expected navigation controller as a root, found \(String(describing: root)) instead")
        XCTAssertTrue(topViewController is FeedViewController, "Expected top view controller of type FeedViewController, found \(String(describing: topViewController)) instead")
    }
}
