//
//  Helpers.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/24.
//

import UIKit

func anyNSError() -> Error {
    NSError(domain: "any-ns-error", code: -1, userInfo: nil)
}

func imageData(color: UIColor) -> Data {
    return UIImage.image(with: color).pngData()!
}

func randomImageData() -> Data {
    let anyColor = UIColor(
        displayP3Red: CGFloat.random(in: 0...1),
        green: CGFloat.random(in: 0...1),
        blue: CGFloat.random(in: 0...1),
        alpha: CGFloat.random(in: 0...1)
    )
    return UIImage.image(with: anyColor).pngData()!
}

func whiteImageData() -> Data {
    return UIImage.image(with: .white).pngData()!
}

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}
