//
//  LoadUserProfileFromRemoteUseCaseTests.swift
//  LoadUserProfileFromRemoteUseCaseTests
//
//  Created by Paul Lee on 2021/10/8.
//

import XCTest
import GitHubAPI
import Alamofire

struct UserProfile: Equatable {
    let id: Int
    let login: String
    let avatarUrl: URL
    let siteAdmin: Bool
}

class RemoteUserProfileLoader {
    struct RemoteUserProfile: Codable {
        let id: Int
        let login: String
        let avatar_url: URL
        let site_admin: Bool
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
        case notModified
    }
    
    let session: Session
    
    let url: URL
    
    init(url: URL, session: Session = .default) {
        self.url = url
        self.session = session
    }
    
    static var nonModifiedStatusCode: Int {
        304
    }
    
    func load(complete: @escaping (Result<[UserProfile], Error>) -> Void) {
        session.request(url).validate(statusCode: [200]).responseDecodable(of: [RemoteUserProfile].self) { response in
            
            if let remoteProfiles = response.value {
                let profiles = remoteProfiles.map { UserProfile(id: $0.id, login: $0.login, avatarUrl: $0.avatar_url, siteAdmin: $0.site_admin) }
                complete(.success(profiles))
                
            } else if response.response?.statusCode == RemoteUserProfileLoader.nonModifiedStatusCode {
                complete(.failure(.notModified))
                
            } else if let error = response.error {
                
                if error.isSessionTaskError {
                    complete(.failure(.connectivity))
                    
                } else {
                    complete(.failure(.invalidData))
                    
                }
                
            }
        }
    }
}

class LoadUserProfileFromRemoteUseCaseTests: XCTestCase {
    func test__loadFromURL__request_with_url() {
        let url = URL(string: "https://my-url.com")!
        let sut = makeSUT(url: url)
        let exp = expectation(description: "wait for request")
        
        var observedRequest: URLRequest?
        URLProtocolStub.requestObserver = { request in
            exp.fulfill()
            observedRequest = request
        }
        
        sut.load { _ in }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observedRequest?.url, url)
        XCTAssertEqual(observedRequest?.httpMethod, "GET")
    }
    
    func test__load__delivers_connectivity_error_on_stubbed_error() {
        let sut = makeSUT()
        
        assertThat(sut, receive: .failure(.connectivity), onStubbedReturns: {
            URLProtocolStub.stub(data: nil, response: nil, error: anyNSError())
        })
    }
    
    func test__load___delivers_invalidData_error_on_un_contracted_status_code() {
        let sut = makeSUT()
        
        assertThat(sut, receive: .failure(.invalidData), onStubbedReturns: {
            URLProtocolStub.stub(data: nil, response: anyHTTPURLResponse(statusCode: 199), error: nil)
        })
    }
    
    func test__load__delivers_invalidData_error_on_non_json() {
        let sut = makeSUT()
        
        assertThat(sut, receive: .failure(.invalidData), onStubbedReturns: {
            let non_json = "any-non-json".data(using: .utf8)!
            URLProtocolStub.stub(data: non_json, response: anyHTTPURLResponse(statusCode: 200), error: nil)
        })
    }
    
    func test__load__delivers_invalidData_error_on_un_contracted_json() {
        let sut = makeSUT()
        
        assertThat(sut, receive: .failure(.invalidData), onStubbedReturns: {
            let un_contracted_json = "{\"key\": \"value\"}".data(using: .utf8)!
            URLProtocolStub.stub(data: un_contracted_json, response: anyHTTPURLResponse(statusCode: 200), error: nil)
        })
    }
    
    func test__load__delivers_nonModified_error_on_304_status_code() {
        let sut = makeSUT()
        
        assertThat(sut, receive: .failure(.notModified), onStubbedReturns: {
            URLProtocolStub.stub(data: nil, response: anyHTTPURLResponse(statusCode: 304), error: nil)
        })
    }
    
    func test__load__delivers_invalidData_on_valid_jsons_with_non_contracted_status_code() {
        let sut = makeSUT()
        let (_, json1) = makeUserProfile()
        let (_, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        
        assertThat(sut, receive: .failure(.invalidData), onStubbedReturns: {
            URLProtocolStub.stub(data: data, response: anyHTTPURLResponse(statusCode: 199), error: nil)
        })
    }
    
    func test__load__delivers_userProfiles_on_valid_json() {
        let sut = makeSUT()
        let (model1, json1) = makeUserProfile()
        let (model2, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        
        assertThat(sut, receive: .success([model1, model2]), onStubbedReturns: {
            URLProtocolStub.stub(data: data, response: anyHTTPURLResponse(statusCode: 200), error: nil)
        })
    }
    
    private func assertThat(_ sut: RemoteUserProfileLoader, receive expectedResult: Result<[UserProfile], RemoteUserProfileLoader.Error>?, onStubbedReturns: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        onStubbedReturns()
        
        let exp = expectation(description: "wait for result")
        var receivedResult: Result<[UserProfile], RemoteUserProfileLoader.Error>?
        sut.load { result in
            exp.fulfill()
            receivedResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedResult) {
            
        case (let .success(receivedProfiles), let .success(expectedProfiles)):
            XCTAssertEqual(receivedProfiles, expectedProfiles, file: file, line: line)
            
        case (let .failure(receivedError), let .failure(expectedError)):
            XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            
        default:
            XCTFail("received \(String(describing: receivedResult)), but expect \(String(describing: expectedResult)) instead", file: file, line: line)
        }
        
    }
    
    private func makeUserProfilesJSON(profiles: [[String: Any]]) -> Data {
        let data = try! JSONSerialization.data(withJSONObject: profiles, options: .prettyPrinted)
        return data
    }
    
    private func makeUserProfile(
        id: Int = Int.random(in: 1...1000),
        login: String = "a-login-name",
        avatarUrl: String = "https://any-url.com",
        siteAdmin: Bool = false
    ) -> (model: UserProfile, json: [String: Any]) {
        let json: [String: Any] = [ "id": id, "login": login, "avatar_url": avatarUrl, "site_admin": siteAdmin]
        let model = UserProfile(id: id, login: login, avatarUrl: URL(string: avatarUrl)! , siteAdmin: siteAdmin)
        return (model, json)
    }
    
    func makeSUT(url: URL? = nil) -> RemoteUserProfileLoader {
        let url = url == nil ? anyURL() : url!
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        return RemoteUserProfileLoader(url: url, session: session)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any-ns-error", code: -1, userInfo: nil)
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.ocm")!
    }
    
    private func anyHTTPURLResponse(statusCode: Int, httpVersion: String? = nil, headerFields: [String : String]? = nil) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: httpVersion, headerFields: headerFields)!
    }
    
    private class URLProtocolStub: URLProtocol {
        
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
    
}
