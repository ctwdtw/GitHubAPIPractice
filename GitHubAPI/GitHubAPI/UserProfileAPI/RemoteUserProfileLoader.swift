//
//  RemoteUserProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/14.
//

import Foundation
import Alamofire

public typealias RemoteUserProfileLoader = RemoteLoader<[UserProfileMapper.RemoteUserProfile], [UserProfile]>
