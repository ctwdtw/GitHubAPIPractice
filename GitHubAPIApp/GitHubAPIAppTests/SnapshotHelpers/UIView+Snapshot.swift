//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import UIKit

extension UIView {
    func defaultSizeSnapshot() -> UIImage {
        return snapshot(for: SnapshotConfiguration.init(size: bounds.size))
    }
    
    func snapshot(size: CGSize) -> UIImage {
        return snapshot(for: SnapshotConfiguration.init(size: size))
    }
    
    @available(iOS 12.0, *)
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        let root = UIViewController()
        root.view = self
        return SnapshotWindow(configuration: configuration, root: root).snapshot()
    }
}
