//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 24/04/21.
//

import XCTest
import EssentialFeed
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let store = InMemoryFeedStore.empty
        let httpClient = HTTPClientStub.online(response)
        let feedVC = launch(store: store, httpClient: httpClient)
        
        XCTAssertEqual(feedVC.numberOfRenderedImageView, 2)
        XCTAssertEqual(feedVC.renderFeedImageDataAt(row: 0), makeImageData())
        XCTAssertEqual(feedVC.renderFeedImageDataAt(row: 1), makeImageData())
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(store: sharedStore, httpClient: HTTPClientStub.online(response))
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(store: sharedStore, httpClient: HTTPClientStub.offline)
        XCTAssertEqual(offlineFeed.numberOfRenderedImageView, 2)
        XCTAssertEqual(offlineFeed.renderFeedImageDataAt(row: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderFeedImageDataAt(row: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        
    }
    
    //MARK: Helpers
    private func launch(store: FeedStore & FeedImageDataStore, httpClient: HTTPClientStub = .offline) -> FeedViewController {
        let httpClient = httpClient
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = (sut.window?.rootViewController as? UINavigationController)
        let feedVC = nav?.topViewController as! FeedViewController
        
        return feedVC
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()

        default:
            return makeFeedData()
        }
    }

    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
