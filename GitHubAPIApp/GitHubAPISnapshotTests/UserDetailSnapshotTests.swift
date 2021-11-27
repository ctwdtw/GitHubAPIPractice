//
//  UserDetailSnapshotTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/26.
//

import XCTest
import GitHubAPIApp

class UserDetailSnapshotTests: XCTestCase {
    func test_detailFieldCell() {
        let sut = TableViewCellSnapshotContainer<DetailFieldCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.icon = UIImage(systemName: "mappin.and.ellipse")
            cell.text = "San Fransisco"
        })
        
        let image = sut.defaultSizeSnapshot(style: .dark)
        
        assert(snapshot: image, named: "detail-field-view-dark")
    }
    
    func test_siteAdminCell() {
        let sut = TableViewCellSnapshotContainer<SiteAdminCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.icon = UIImage(systemName: "person.fill")
            cell.loginText = "defunkt"
            cell.isSiteAdmin = true
            cell.siteAdminText = "STAFF"
        })
        
        let image = sut.defaultSizeSnapshot(style: .dark)
        
        assert(snapshot: image, named: "site-admin-cell-dark")
    }
}
