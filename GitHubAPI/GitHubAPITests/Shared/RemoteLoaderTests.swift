//
//  RemoteLoaderTests.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/19.
//

import XCTest
import GitHubAPI
import Alamofire

class RemoteLoaderTests: XCTestCase {
    func test__loadFromURL__request_with_url() {
        let url = URL(string: "https://my-url.com")!
        let sut = makeSUT(url: url)
        
        assertThat(sut.load(complete:), request: url, httpMethod: "GET")
    }
    
    func test__load__delivers_mapped_error() {
        let sut = makeSUT(mapping: { _ in
            throw anyNSError()
        })

        assertThat(sut.load(complete:), receive: .failure(anyNSError()))
    }
    
    func test__load__delivers_mapped_resource() {
        let sut = makeSUT(mapping: { _ in
            "a-resource"
        })
        
        assertThat(sut.load(complete:), receive: .success("a-resource"))
    }
        
    func test__load__delivers_loaderHasDeallocated_error_on_sut_deinit_before_session_complete() {
        var sut: RemoteLoader? = makeSUT()
        
        let exp = expectation(description: "wait for result")
        
        var receivedError: Error?
        sut?.load { result in
            exp.fulfill()
            receivedError = result.error
        }
        
        sut = nil
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, StringLoader.Error.loaderHasDeallocated as NSError?)
    }
    
    typealias StringLoader = RemoteLoader<String>
    func makeSUT(url: URL? = nil, mapping: @escaping StringLoader.Mapping = { _ in
        "a-resource"
    }) -> StringLoader {
        let url = url == nil ? anyURL() : url!
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        return StringLoader(url: url, session: session, mapping: mapping)
    }
    
    //MARK: - helpers
    private typealias LoadAction = ((@escaping StringLoader.Complete) -> Void)
    private func assertThat(_ loadAction: LoadAction, request url: URL, httpMethod: String = "GET", file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for request")
        
        var observedRequest: URLRequest?
        URLProtocolStub.requestObserver = { request in
            exp.fulfill()
            observedRequest = request
        }
        
        loadAction { _ in }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observedRequest?.url, url, file: file, line: line)
        XCTAssertEqual(observedRequest?.httpMethod, httpMethod, file: file, line: line)
    }
    
    @discardableResult
    private func assertThat(_ loadAction: LoadAction, receive expectedResult: StringLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> StringLoader.Result? {
        let exp = expectation(description: "wait for result")
        var receivedResult: StringLoader.Result?
        loadAction() { result in
            exp.fulfill()
            receivedResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedResult) {
            
        case (let .success(receivedProfiles), let .success(expectedProfiles)):
            XCTAssertEqual(receivedProfiles, expectedProfiles, file: file, line: line)
            return receivedResult
        
        case (let .failure(receivedError), let .failure(expectedError)):
            XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            return nil
        
        default:
            XCTFail("received \(String(describing: receivedResult)), but expect \(String(describing: expectedResult)) instead", file: file, line: line)
            return nil
        }
        
    }
}

private extension RemoteLoader {
    @discardableResult
    func stub(data: Data?, response: HTTPURLResponse?, error: Swift.Error?) -> RemoteLoader {
        URLProtocolStub.stub(data: data, response: response, error: error)
        return self
    }
}

private extension Result {
    var error: Error? {
        switch self {
        case .success(_):
            return nil
        case .failure(let error):
            return error
        }
    }
}
