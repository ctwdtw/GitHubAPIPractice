//
//  RefreshViewModel.swift
//  GitHubAPIApp
//
//  Created by Paul Lee on 2021/11/9.
//

import Foundation
import GitHubAPI

public class RefreshViewModel {
    var onStartLoading: (() -> Void)?
    
    var onFinishLoading: (() -> Void)?
    
    var onRefreshed: ((ListViewController.TableModel) -> Void)?
    
    public var loadAction: (() -> Void)?
    
    public init() {}
}
