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
        let feedVC = launch(store: InMemoryFeedStore.empty, httpClient: HTTPClientStub.online(response))
        
        XCTAssertEqual(feedVC.numberOfRenderedImageView, 2)
        XCTAssertEqual(feedVC.renderFeedImageDataAt(row: 0), makeImageData())
        XCTAssertEqual(feedVC.renderFeedImageDataAt(row: 1), makeImageData())
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        
    }
    
    //MARK: Helpers
    private func launch(store: FeedStore & FeedImageDataCache, httpClient: HTTPClientStub = .offline) -> FeedViewController {
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
