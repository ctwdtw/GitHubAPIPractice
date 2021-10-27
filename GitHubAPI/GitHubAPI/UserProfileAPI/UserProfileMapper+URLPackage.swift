//
//  UserProfileMapper+URLPackage.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/27.
//

import Foundation
import Alamofire

public struct UserProfileURLPackage {
    public let userProfiles: [UserProfile]
    public let nextURL: URL?
    
    public init(userProfiles: [UserProfile], nextURL: URL?) {
        self.userProfiles = userProfiles
        self.nextURL = nextURL
    }
}

public protocol URLPackageMapping {
    typealias URLPackageMapping = (DataResponse<Data, AFError>) throws -> UserProfileURLPackage
    func map(_ response: DataResponse<Data, AFError>) throws -> UserProfileURLPackage
}

public extension UserProfileMapper {
    func map(_ response: DataResponse<Data, AFError>) throws -> UserProfileURLPackage {
        do {
            let linkString = response.response?.value(forHTTPHeaderField: "Link")
            let item: [UserProfile] = try self.map(response)
            return UserProfileURLPackage(userProfiles: item, nextURL: nextURL(linkString))
        } catch {
            throw error
        }
    }
    
    private func nextURL(_ linkField: String?) -> URL? {
        guard let link = linkField?.split(separator: ",").first(where: {
            return String($0).contains("next")
            
        }) else {
            return nil
        }
        
        guard let range = link.range(of: "(?<=\\<).+?(?=\\>)", options: .regularExpression) else {
            return nil
        }
        
        guard let url = URL(string: String(link[range])) else {
            return nil
        }
        
        return url

    }
}
