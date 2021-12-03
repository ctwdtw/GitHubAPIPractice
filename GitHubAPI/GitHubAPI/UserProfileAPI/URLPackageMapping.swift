//
//  URLPackageMapping.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/11/12.
//

import Foundation
import Alamofire

public protocol URLPackageMapping {
    typealias URLPackageMapping = (DataResponse<Data, AFError>) throws -> UserProfileURLPackage
    func map(_ response: DataResponse<Data, AFError>) throws -> UserProfileURLPackage
}
