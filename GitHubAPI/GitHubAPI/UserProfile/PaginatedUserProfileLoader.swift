//
//  PaginatedUserProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/28.
//

import Foundation
import Alamofire

public class PaginatedUserProfileLoader {
    public typealias Complete = PaginatedUserProfile.Complete
    
    public typealias Result = PaginatedUserProfile.Result
    
    private let adaptee: RemoteLoader<UserProfileURLPackage>
    
    private let session: Session
    
    private let mapping: URLPackageMapping.URLPackageMapping
    
    private var currentProfiles: [UserProfile]
    
    public init(url: URL, session: Session, mapping: @escaping URLPackageMapping.URLPackageMapping, currentProfiles: [UserProfile] = []) {
        self.adaptee =  RemoteLoader<UserProfileURLPackage>(url: url, session: session, mapping: mapping)
        self.session = session
        self.mapping = mapping
        self.currentProfiles = currentProfiles
    }
    
    public func load(complete: @escaping Complete) {
        adaptee.load { result in
            complete(
                result.map { loadedPackage in
                    self.currentProfiles = self.currentProfiles + loadedPackage.userProfiles
                    return PaginatedUserProfile(
                        userProfiles:  self.currentProfiles,
                        loadMore: self.makeLoadMore(from: loadedPackage)
                    )
                }
            )
        }
    }
    
    private func makeLoadMore(from package: UserProfileURLPackage) -> PaginatedUserProfile.LoadMoreAction? {
        guard let nextURL = package.nextURL else { return nil }
        return PaginatedUserProfileLoader(url: nextURL, session: session, mapping: mapping, currentProfiles: currentProfiles).load(complete:)
    }
}
