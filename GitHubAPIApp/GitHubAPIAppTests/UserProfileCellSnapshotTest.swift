//
//  UserProfileCellSnapshotTest.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/11.
//

import XCTest
import GitHubAPI
import GitHubAPIApp

class UserProfileCellSnapshotTest: XCTestCase {
    func test_userProfileCell_showSiteAdminLabel() {
        let sut = TableViewCellSnapshotContainer<UserProfileCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.avatarImageView.image = UIImage.make(withColor: .blue)
            cell.loginLabel.text = "login-account"
            cell.siteAdminLabel.isHidden = false
        })
        
        let image = sut.defaultSizeSnapshot()
        
        assert(snapshot: image, named: "UserProfileCell-siteAdmin")
    }
    
    func test_userProfileCell_hideSiteAdminLabel() {
        let sut = TableViewCellSnapshotContainer<UserProfileCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.avatarImageView.image = UIImage.make(withColor: .blue)
            cell.loginLabel.text = "login-account"
        })
        
        let image = sut.defaultSizeSnapshot()
        
        assert(snapshot: image, named: "UserProfileCell")
    }
}
