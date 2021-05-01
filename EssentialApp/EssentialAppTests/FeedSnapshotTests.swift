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
        sut.display(emptyFeeds())
        
        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .dark)), named: "EMPTY_Feed_Dark")
        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .light)), named: "EMPTY_Feed_Light")
    }
    
    func test_emptyFeedWithContent() {
        let sut =  makeSUT ()
        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_Dark")
        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
    }
    
    func test_feedWithError() {
        let sut =  makeSUT ()
        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .dark)), named: "FEED_WITH_ErrorMessage_Dark")
        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .light)), named: "FEED_WITH_ErrorMessage_light")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut =  makeSUT ()
        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .dark)), named: "FEED_WITH_FailedImage_Dark")
        assert(snapshot: sut.snapshot(for: SnapshotConfiguration.iPhone8(style: .light)), named: "FEED_WITH_FailedImage_light")
    }
    
    //MARK: - Helpers
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: bundle)
        let feedViewController = storyBoard.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
        feedViewController.loadViewIfNeeded()
        feedViewController.tableView.showsVerticalScrollIndicator = false
        feedViewController.tableView.showsHorizontalScrollIndicator = false
        return feedViewController
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Canon street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Bridgton SeaFront",
                image: nil
            )
        ]
    }
    
    private func assert(snapshot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        
        let snapshotURL = makeSnapshotURL(named: named, file: file)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    private func makeSnapshotData(snapshot: UIImage, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG Data from snapshot", file: file, line: line)
            return nil
        }
        return snapshotData
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
    private func emptyFeeds() -> [FeedImageCellController] {
        return []
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func record(snapshot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotData = makeSnapshotData(snapshot: snapshot)
        
        let snapshotURL = makeSnapshotURL(named: named, file: file)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
           try snapshotData?.write(to: snapshotURL)
        }
        catch {
            XCTFail("Failed to record snapshot for test", file: file, line: line)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map {
            let cellController = FeedImageCellController(delegate: $0)
            $0.cellController = cellController
            return cellController
        }
        display(cells)
    }
}

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .available),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: .medium),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 2),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ]))
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    weak var cellController: FeedImageCellController?
    var viewModel: FeedImageViewModel<UIImage>

    init(description: String?,
         location: String,
         image: UIImage?) {
        viewModel = FeedImageViewModel<UIImage>(location: location,
                                                description: description,
                                                image: image,
                                                isLoading: false,
                                                showRetry: image == nil)
    }
    
    func didRequestImage() {
        cellController?.display(viewModel)
    }
    
    func didCancelImageRequest() {
        
    }
}
