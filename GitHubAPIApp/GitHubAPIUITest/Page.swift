//
//  Page.swift
//  GitHubAPIUITest
//
//  Created by Paul Lee on 2021/12/2.
//

import Foundation
import XCTest

protocol Page {
    var app: XCUIApplication { get }
    func wait(seconds: UInt32) -> Self
}

extension Page {
    func wait(seconds: UInt32) -> Self {
        sleep(seconds)
        return self
    }
}
