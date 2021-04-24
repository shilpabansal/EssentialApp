//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 15/04/21.
//

import Foundation
import EssentialFeed

func  anyNSError () -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeeds() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)]
}

func uniqueFeed() -> FeedImage {
    return FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)
}

public func uniqueImageFeeds() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let feeds = [uniqueFeed(), uniqueFeed()]
    let localFeeds = feeds.map({feed in
        LocalFeedImage(id: feed.id, description: feed.description, location: feed.location, url: feed.url)
    })
    
    return (model: feeds, local: localFeeds)
}
