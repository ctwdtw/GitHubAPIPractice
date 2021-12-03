//
//  UserProfileUIIntegrationTests+Assertions.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/23.
//

import Foundation
import XCTest
import GitHubAPI
import GitHubAPIApp

func assertThat(_ sut: ListViewController,
                        rendering userProfiles: [UserProfile],
                        file: StaticString = #filePath,
                        line: UInt = #line
) {
    XCTAssertEqual(sut.numberOfRenderedUserProfile, userProfiles.count, "receive \(sut.numberOfRenderedUserProfile) user profiles, but expect \(userProfiles.count)", file: file, line: line)
    
    userProfiles.enumerated().forEach { (idx, userProfile) in
        assertThat(sut, hasViewConfiguredFor: userProfile, at: idx, file: file, line: line)
    }
}

func assertThat(_ sut: ListViewController, hasViewConfiguredFor userProfile: UserProfile, at idx: Int, file: StaticString = #filePath, line: UInt = #line) {
    let view = sut.userProfileView(at: idx)
    guard let cell =  view as? UserProfileCell else {
        return XCTFail("receive \(String(describing: view)) instead, but expect it to be \(UserProfileCell.self) instance at index: \(idx), but got", file: file, line: line)
    }
    
    XCTAssertEqual(cell.loginAccountText, userProfile.login, "receive login account text \(String(describing: cell.loginAccountText)), but expect it to be \(userProfile.login) instead.", file: file, line: line)
    
    XCTAssertEqual(cell.showSiteAdminLabel, userProfile.siteAdmin, "receive show site admin label to be \(cell.showSiteAdminLabel), but expect it to be \(userProfile.siteAdmin) ", file: file, line: line)
}
