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

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "https://a-url.com")!)]
}
