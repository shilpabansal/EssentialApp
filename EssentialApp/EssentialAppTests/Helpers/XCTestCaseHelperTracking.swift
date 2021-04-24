//
//  XCTestCaseHelperTracking.swift
//  NetworkModularizationTests
//
//  Created by Shilpa Bansal on 07/01/21.
//

import XCTest

public extension XCTestCase {
    func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated, potential memory leak", file: file, line: line)
        }
    }
}
