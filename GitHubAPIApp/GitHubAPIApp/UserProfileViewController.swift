//
//  UserProfileViewController.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/10/8.
//

import UIKit
import GitHubAPI

public protocol UserProfileLoader {
    typealias Result = Swift.Result<[UserProfile], Swift.Error>
    typealias Complete = (Result) -> Void
    func load(complete: @escaping Complete)
}

public class UserProfileCell: UITableViewCell {
    public let loginLabel = UILabel()
    public let siteAdminLabel = UILabel()
}

public class UserProfileViewController: UITableViewController {
    private var loader: UserProfileLoader!
    
    private var userProfiles: [UserProfile] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public convenience init(loader: UserProfileLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader.load { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.refreshControl?.endRefreshing()
            let items = try! result.get()
            self.userProfiles = items
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = userProfiles[indexPath.row]
        let cell = UserProfileCell()
        cell.loginLabel.text = item.login
        cell.siteAdminLabel.isHidden = !item.siteAdmin
        
        return cell
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfiles.count
    }
}

/*
    [v] Load feed automatically when view is presented
    [v] Allow customer to manually reload feed (pull to refresh)
    [v] Show a loading indicator while loading feed
       -> 包含 view is presented 和 user pull to refresh 兩種情況下的 loading,
          都要考慮 loading indicator
    [] Render all loaded feed items (location, image, description)
    [] Image loading experience
        [] Load when image view is visible (on screen)
        [] Cancel when image view is out of screen
        [] Show a loading indicator while loading image (shimmer)
        [] Option to retry on image download error
        [] Preload when image view is near visible
*/
