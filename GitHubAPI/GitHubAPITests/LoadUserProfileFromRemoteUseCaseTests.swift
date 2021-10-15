//
//  LoadUserProfileFromRemoteUseCaseTests.swift
//  LoadUserProfileFromRemoteUseCaseTests
//
//  Created by Paul Lee on 2021/10/8.
//

import XCTest
import GitHubAPI
import Alamofire

class LoadUserProfileFromRemoteUseCaseTests: XCTestCase {
    func test__loadFromURL__request_with_url() {
        let url = URL(string: "https://my-url.com")!
        let sut = makeSUT(url: url)
        
        assertThat(sut.load(complete:), request: url, httpMethod: "GET")
    }

    func test__load__delivers_connectivity_error_on_stubbed_error() {
        let sut = makeSUT().stub(data: nil, response: nil, error: anyNSError())
        
        assertThat(sut.load(complete:), receive: .failure(.connectivity))
    }
    
    func test__load___delivers_invalidData_error_on_un_contracted_status_code() {
        let sut = makeSUT().stub(data: nil, response: anyHTTPURLResponse(statusCode: 199), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(.invalidData))
    }
    
    func test__load__delivers_invalidData_error_on_non_json() {
        let data = "any-non-json".data(using: .utf8)!
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200), error: nil)
    
        assertThat(sut.load(complete:), receive: .failure(.invalidData))
    }
    
    func test__load__delivers_invalidData_error_on_un_contracted_json() {
        let data = "{\"key\": \"value\"}".data(using: .utf8)!
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(.invalidData))
    }
    
    func test__load__delivers_nonModified_error_on_304_status_code() {
        let sut = makeSUT().stub(data: nil, response: anyHTTPURLResponse(statusCode: 304), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(.notModified))
    }
    
    func test__load__delivers_invalidData_on_valid_jsons_with_non_contracted_status_code() {
        let (_, json1) = makeUserProfile()
        let (_, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 199), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(.invalidData))
    }
    
    func test__load__delivers_userProfiles_on_valid_json() {
        let (model1, json1) = makeUserProfile()
        let (model2, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200), error: nil)
        
        assertThat(sut.load(complete:), receive: .success([model1, model2]))
    }
        
    func test__load__delivers_loaderHasDeallocated_error_on_sut_deinit_before_session_complete() {
        var sut: RemoteUserProfileLoader? = makeSUT()
        
        let exp = expectation(description: "wait for result")
        
        var receivedError: Error?
        sut?.load { result in
            exp.fulfill()
            receivedError = result.error
        }
        
        sut = nil
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, UserProfileMapper.Error.loaderHasDeallocated as NSError?)
    }

    
    func makeSUT(url: URL? = nil) -> RemoteUserProfileLoader {
        let url = url == nil ? anyURL() : url!
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        return RemoteUserProfileLoader(url: url, session: session, mapper: UserProfileMapper())
    }
    
    //MARK: - helpers
    private func assertThat(_ loadAction: LoadAction, request url: URL, httpMethod: String = "GET") {
        let exp = expectation(description: "wait for request")
        
        var observedRequest: URLRequest?
        URLProtocolStub.requestObserver = { request in
            exp.fulfill()
            observedRequest = request
        }
        
        loadAction { _ in }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observedRequest?.url, url)
        XCTAssertEqual(observedRequest?.httpMethod, httpMethod)
    }
    
    @discardableResult
    private func assertThat(_ loadAction: LoadAction, receive expectedResult: LoadUserProfileResult, file: StaticString = #filePath, line: UInt = #line) -> LoadUserProfileResult? {
        let exp = expectation(description: "wait for result")
        var receivedResult: LoadUserProfileResult?
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

private extension RemoteUserProfileLoader {
    @discardableResult
    func stub(data: Data?, response: HTTPURLResponse?, error: Swift.Error?) -> RemoteUserProfileLoader {
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
