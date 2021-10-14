//
//  PaginatedUserProfileAdapter.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/14.
//

import Foundation
public typealias PaginatedUserProfileResult = Result<PaginatedUserProfile, RemoteUserProfileLoader.Error>
public typealias PaginatedLoadUserProfileComplete = (PaginatedUserProfileResult) -> Void
public typealias PaginatedLoadMoreAction = ((@escaping PaginatedLoadUserProfileComplete) -> Void)

public  class PaginatedUserProfileAdapter {
    private let adaptee: RemoteUserProfileLoader
    
    private var currentProfiles: [UserProfile]
    
    public  init(adaptee: RemoteUserProfileLoader, currentProfiles: [UserProfile]) {
        self.adaptee = adaptee
        self.currentProfiles = currentProfiles
    }
    
    public  func load(complete: @escaping PaginatedLoadUserProfileComplete) {
        adaptee.load { [adaptee, linkKey] result in
            let page: PaginatedUserProfileResult = result.map { profiles in
                
                self.currentProfiles += profiles
                
                var loadMore: PaginatedLoadMoreAction?
                
                if let link = adaptee.mapper.currentHeaders?[linkKey] as? String, let url = self.nextURL(from: link) {
                    let loader = RemoteUserProfileLoader(url: url, session: adaptee.session, mapper: adaptee.mapper)
                    loadMore = PaginatedUserProfileAdapter(adaptee: loader, currentProfiles: self.currentProfiles).load(complete:)
                }
                
                let pageProfiles = PaginatedUserProfile(
                    profiles: self.currentProfiles,
                    loadMore: loadMore
                )
                
                return pageProfiles
                
            }
            
            complete(page)
        }
    }
    
    //MARK: - paginated api detail
    private let linkKey = "Link"
    
    private func nextURL(from linkHeader: String) -> URL? {
        guard let nextLink = linkHeader.split(separator: ",").filter({ $0.contains("next") }).first else {
            return nil
        }
        
        guard let range = nextLink.range(of: "(?<=\\<).+?(?=\\>)", options: .regularExpression) else {
            return nil
        }
        
        guard let url = URL(string: String(nextLink[range])) else {
            return nil
        }
        
        return url
    }
    
}
