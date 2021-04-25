//
//  FeedSnapshotTests.swift
//  EssentialAppTests
//
//  Created by Shilpa Bansal on 25/04/21.
//
import XCTest
import EssentialFeed

class FeedSnapshotTests: XCTestCase {
    func test_emptyFeeds() {
        let sut = makeSUT()
        sut.display(cellController: emptyFeeds())
        let snapshot = sut.snapshot()
        
        record(snapshot: snapshot, fileName: "EMPTY_Feed")
    }
    
    //MARK: - Helpers
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let feedViewController = storyBoard.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        feedViewController.loadViewIfNeeded()
        return feedViewController
    }
    
    private func emptyFeeds() -> [FeedImageCellController] {
        return []
    }
    
    private func record(snapshot: UIImage, fileName: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG Data from snapshot", file: file, line: line)
            return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(fileName).png")
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
           try snapshotData.write(to: snapshotURL)
        }
        catch {
            XCTFail("Failed to record snapshot for test", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { (action) in
            view.layer.render(in: action.cgContext)
        }
    }
}
