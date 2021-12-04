//
//  UserDetailSnapshotTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/26.
//

import XCTest
@testable import GitHubAPIApp

class UserDetailSnapshotTests: XCTestCase {
    func test_detailFieldCell() {
        let sut = TableViewCellSnapshotContainer<DetailFieldCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.icon = UIImage(systemName: "mappin.and.ellipse")
            cell.detailText = "San Fransisco"
        })
        
        assert(snapshot: sut.defaultSizeSnapshot(style: .dark), named: "detail-field-cell-dark")
    }
    
    func test_siteAdminCell() {
        let sut = TableViewCellSnapshotContainer<SiteAdminCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.icon = UIImage(systemName: "person.fill")
            cell.loginText = "defunkt"
            cell.isSiteAdmin = true
            cell.siteAdminText = "STAFF"
        })
        
        assert(snapshot: sut.defaultSizeSnapshot(style: .dark), named: "site-admin-cell-dark")
    }
    
    func test_avatarCell() {
        let sut = TableViewCellSnapshotContainer<AvatarCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.name = "Chris Wanstrath"
            cell.biography = "🍔"
            cell.avatarImage = UIImage.image(with: .red)
        })
        
        assert(snapshot: sut.defaultSizeSnapshot(style: .dark), named: "avatar-cell-dark")
    }
    
    func test_avatarCell_Retry() {
        let sut = TableViewCellSnapshotContainer<AvatarCell>(width: .iPhone11, cellConfigurator: { cell in
            cell.name = "Chris Wanstrath"
            cell.biography = "🍔"
            cell.shouldRetry = true
        })
        
        assert(snapshot: sut.defaultSizeSnapshot(style: .dark), named: "avatar-cell-retry-dark")
    }
    
    func test_UserDetailViewController() {
        let sut = makeSUT()
    
        sut.display(userDetailSiteAdmin())
        
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "user-detail-light")
        assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "user-detail-dark")
    }
    
    private func userDetailSiteAdmin() -> ListViewController.TableModel {
        let siteAdminController = CellController(dataSource: SiteAdminStub(isSiteAdmin: true))
        let avatarController = CellController(dataSource: AvatarStub())
        let locationController = CellController(dataSource: LocationStub())
        let blogController = CellController(dataSource: BlogStub())
        return [[avatarController, siteAdminController, locationController, blogController]]
    }
    
    private class AvatarStub: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableView.dummyNumberOfSection
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = AvatarCell()
            cell.name = "Chris Wanstrath"
            cell.biography = "🍔"
            cell.avatarImage = UIImage.image(with: .red)
            return cell
        }
    }
    
    private class SiteAdminStub: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableView.dummyNumberOfSection
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = SiteAdminCell()
            cell.icon = UIImage(systemName: "person.fill")
            cell.isSiteAdmin = isSiteAdmin
            cell.loginText = "defunkt"
            return cell
        }
        
        private let isSiteAdmin: Bool
        
        init(isSiteAdmin: Bool = false) {
            self.isSiteAdmin = isSiteAdmin
        }
    }
    
    private class LocationStub: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableView.dummyNumberOfSection
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = DetailFieldCell()
            cell.icon = UIImage(systemName: "mappin.and.ellipse")
            cell.detailText = "San Fransisco"
            return cell
        }
    }
    
    private class BlogStub: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            tableView.dummyNumberOfSection
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = DetailFieldCell()
            cell.icon = UIImage(systemName: "link")
            cell.detailText = "http://chriswanstrath.com/"
            cell.textColor = .link
            return cell
        }
    }
    
    private func makeSUT() -> ListViewController {
        let sut = ListViewController()
        return sut
    }
    
    
}
