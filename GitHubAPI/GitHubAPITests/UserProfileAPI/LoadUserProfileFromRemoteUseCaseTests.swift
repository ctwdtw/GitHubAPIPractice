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
    func test__load__delivers_connectivity_error_on_stubbed_error() {
        let sut = makeSUT().stub(data: nil, response: nil, error: anyNSError())
        
        assertThat(sut.load(complete:), receive: .failure(UserProfileMapper.Error.connectivity))
    }
    
    func test__load___delivers_invalidData_error_on_un_contracted_status_code() {
        let sut = makeSUT().stub(data: nil, response: anyHTTPURLResponse(statusCode: 199), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(UserProfileMapper.Error.invalidData))
    }
    
    func test__load__delivers_invalidData_error_on_non_json() {
        let data = "any-non-json".data(using: .utf8)!
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200), error: nil)
    
        assertThat(sut.load(complete:), receive: .failure(UserProfileMapper.Error.invalidData))
    }
    
    func test__load__delivers_invalidData_error_on_un_contracted_json() {
        let data = "{\"key\": \"value\"}".data(using: .utf8)!
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(UserProfileMapper.Error.invalidData))
    }
    
    func test__load__delivers_nonModified_error_on_304_status_code() {
        let sut = makeSUT().stub(data: nil, response: anyHTTPURLResponse(statusCode: 304), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(UserProfileMapper.Error.notModified))
    }
    
    func test__load__delivers_invalidData_on_valid_jsons_with_non_contracted_status_code() {
        let (_, json1) = makeUserProfile()
        let (_, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 199), error: nil)
        
        assertThat(sut.load(complete:), receive: .failure(UserProfileMapper.Error.invalidData))
    }
    
    func test__load__delivers_userProfiles_on_valid_json() {
        let (model1, json1) = makeUserProfile()
        let (model2, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200), error: nil)
        
        assertThat(sut.load(complete:), receive: .success([model1, model2]))
    }
        
    func makeSUT(url: URL? = nil) -> RemoteUserProfileLoader {
        let url = url == nil ? anyURL() : url!
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        return RemoteUserProfileLoader(url: url, session: session, mapping: UserProfileMapper().map(_:))
    }
    
    //MARK: - helpers
    private typealias LoadAction = ((@escaping RemoteUserProfileLoader.Complete) -> Void)
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
    private func assertThat(_ loadAction: LoadAction, receive expectedResult: RemoteUserProfileLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> RemoteUserProfileLoader.Result? {
        let exp = expectation(description: "wait for result")
        var receivedResult: RemoteUserProfileLoader.Result?
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
