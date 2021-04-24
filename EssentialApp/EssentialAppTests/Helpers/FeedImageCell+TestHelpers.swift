//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeedTests
//
//  Created by Shilpa Bansal on 24/04/21.
//

import UIKit
import EssentialFeed
extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}
