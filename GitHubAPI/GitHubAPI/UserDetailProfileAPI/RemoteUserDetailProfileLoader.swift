//
//  RemoteUserDetailProfileLoader.swift
//  GitHubAPI
//
//  Created by Paul Lee on 2021/10/18.
//

import Foundation
import Alamofire

public typealias RemoteUserDetailProfileLoader = RemoteLoader<[UserDetailProfileMapper.RemoteUserDetailProfile], [UserDetailProfile]>
