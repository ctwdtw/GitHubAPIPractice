//
//  UserProfileMapper+URLPackage.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/27.
//

import Foundation
import Alamofire

public extension UserProfileMapper {
    func map(_ response: DataResponse<Data, AFError>) throws -> UserProfileURLPackage {
        do {
            let linkString = response.response?.value(forHTTPHeaderField: "Link")
            let item: [UserProfile] = try self.map(response)
            return UserProfileURLPackage(item, nextURL: nextURL(linkString))
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
