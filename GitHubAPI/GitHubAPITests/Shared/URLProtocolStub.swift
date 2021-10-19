//
//  URLProtocolStub.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/14.
//

import Foundation
//MARK: - test doubles
class URLProtocolStub: URLProtocol {
    
    static var requestObserver: ((URLRequest?) -> Void)?
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let observer = URLProtocolStub.requestObserver {
            client?.urlProtocolDidFinishLoading(self)
            observer(request)
        }
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.httpUrlResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        URLProtocolStub.requestObserver = nil
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    struct Stub {
        var data: Data?
        var httpUrlResponse: HTTPURLResponse?
        var error: Swift.Error?
    }
    
    static private var stub: Stub?
    
    static func stub(data: Data?, response: HTTPURLResponse?, error: Swift.Error?) {
        stub = Stub(data: data, httpUrlResponse: response, error: error)
        
    }
}
