//
//  PaginatedUserProfileAdapter.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/14.
//

import Foundation
public typealias PaginatedUserProfileResult = Result<PaginatedUserProfile, Swift.Error>
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
        adaptee.load { [weak self] result in
            guard let self = self else {
                complete(.failure(UserProfileMapper.Error.loaderHasDeallocated))
                return
            }
            
            let page: PaginatedUserProfileResult = result.map { profiles in
                self.currentProfiles += profiles
                return PaginatedUserProfile(
                    profiles: self.currentProfiles,
                    loadMore: self.makeLoadMore()
                )
            }
            
            complete(page)
        }
    }
    
    private func makeLoadMore() -> PaginatedLoadMoreAction? {
        if let url = adaptee.mapper.nextURL() {
            let loader = RemoteUserProfileLoader(url: url, session: adaptee.session, mapper: adaptee.mapper)
            return PaginatedUserProfileAdapter(adaptee: loader, currentProfiles: self.currentProfiles).load(complete:)
        
        } else {
            
            return nil
        }
    }
}
