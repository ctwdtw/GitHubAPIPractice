//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit

extension UIView {
    func defaultSizeSnapshot(style: UIUserInterfaceStyle = .light) -> UIImage {
        return snapshot(size: bounds.size, style: style)
    }
    
    func snapshot(size: CGSize, style: UIUserInterfaceStyle) -> UIImage {
        let traitCollection = UITraitCollection(traitsFrom: [.init(userInterfaceStyle: style)])
        return snapshot(for: SnapshotConfiguration.init(size: size, traitCollection: traitCollection))
    }
    
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        let root = UIViewController()
        root.view = self
        return SnapshotWindow(configuration: configuration, root: root).snapshot()
    }
}
