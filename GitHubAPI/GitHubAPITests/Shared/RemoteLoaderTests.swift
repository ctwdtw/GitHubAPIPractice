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
    
    /// 不論 mapper 是什麼, generic loader 和 mapper 的 integration test 都會
    /// 讓 generic loader deliver connectivity error.
    /// 也許這個 test case 不該存在, 已經由下一個 test case cover 了.
//    func test__load__delivers_connectivity_error_on_stubbed_error() {
//        let sut = makeSUT().stub(data: nil, response: nil, error: anyNSError())
//
//        assertThat(sut.load(complete:), receive: .failure(IntToStringLoader.Error.connectivity))
//    }

    func test__load__delivers_error_on_mapper_error() {
        let mapper = ResourceMapper(error: anyNSError())
        let sut = makeSUT(mapper: mapper)

        assertThat(sut.load(complete:), receive: .failure(anyNSError()))
    }
    
    func test__load__delivers_mapped_resource() {
        let mapper = ResourceMapper(resource: "a-resource")
        let sut = makeSUT(mapper: mapper)
        
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
        XCTAssertEqual(receivedError as NSError?, IntToStringLoader.Error.loaderHasDeallocated as NSError?)
    }
    
    typealias IntToStringLoader = RemoteLoader<Int, String>
    func makeSUT(url: URL? = nil, mapper: ResourceMapper = ResourceMapper(resource: "a-resource")) -> IntToStringLoader {
        let url = url == nil ? anyURL() : url!
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        return IntToStringLoader(url: url, session: session, mapper: mapper)
    }
    
    class ResourceMapper: Mapper {
        typealias RemoteResource = Int
        
        typealias Resource = String
        
        var validStatusCodes: [Int] = []
        
        private var resource: String?
        
        init(resource: String) {
            self.resource = resource
        }
        
        private var error: Error?
        
        init(error: Error) {
            self.error = error
        }
        
        func map(_ response: DataResponse<Int, AFError>) throws -> String {
            if let res = resource {
                return res
            
            } else if let e = error {
                throw e
                
            } else {
                throw anyNSError()
                
            }
        }
    }
    
    //MARK: - helpers
    private typealias LoadAction = ((@escaping IntToStringLoader.ResourceComplete) -> Void)
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
    private func assertThat(_ loadAction: LoadAction, receive expectedResult: IntToStringLoader.ResourceResult, file: StaticString = #filePath, line: UInt = #line) -> IntToStringLoader.ResourceResult? {
        let exp = expectation(description: "wait for result")
        var receivedResult: IntToStringLoader.ResourceResult?
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
