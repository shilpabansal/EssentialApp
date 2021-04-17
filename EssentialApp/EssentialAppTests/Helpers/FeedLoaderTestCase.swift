//
//  FeedLoaderTestCase.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 17/04/21.
//

import XCTest
import EssentialFeed

protocol  FeedLoaderTeseCase: XCTestCase {}

extension FeedLoaderTeseCase {
    func expect(sut: FeedLoader, toCompleteWith: FeedLoader.Result) {
        let exp = expectation(description: "Wait for API")
        
        sut.load { receivedResult in
            switch (receivedResult, toCompleteWith) {
            case let (.success(receivedFeeds), .success(expectedFeeds)):
                XCTAssertEqual(receivedFeeds, expectedFeeds)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError.localizedDescription, expectedError.localizedDescription)
            default:
                XCTFail("Expected \(toCompleteWith) Received \(receivedResult)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}

class FeedLoaderStub: FeedLoader {
   private var result: FeedLoader.Result
   init(result: FeedLoader.Result) {
       self.result = result
   }
   
   func load(completion: @escaping ((FeedLoader.Result) -> Void)) {
       completion(result)
   }
}
