//
//  UIButton+TestHelpers.swift
//  EssentialFeedTests
//
//  Created by Shilpa Bansal on 24/04/21.
//

import UIKit
extension UIButton {
    func simulateTap() {
        allTargets.forEach({target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}
