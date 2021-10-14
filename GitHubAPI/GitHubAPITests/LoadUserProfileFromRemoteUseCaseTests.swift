//
//  LoadUserProfileFromRemoteUseCaseTests.swift
//  LoadUserProfileFromRemoteUseCaseTests
//
//  Created by Paul Lee on 2021/10/8.
//

import XCTest
import GitHubAPI
import Alamofire

class UserProfileMapper {
    var validStatusCodes: [Int] {
        return [200]
    }
    
    var nonModifiedStatusCode: Int {
        304
    }
    
    private let session: Session
    
    private var currentProfiles: [UserProfile]
    
    init(session: Session, currentProfiles: [UserProfile] = []) {
        self.session = session
        self.currentProfiles = currentProfiles
    }
    
    func map(_ response: DataResponse<[RemoteUserProfileLoader.RemoteUserProfile], AFError>) -> LoadUserProfileResult {
        if let remoteProfiles = response.value {
            
            let profiles = remoteProfiles.map { UserProfile(id: $0.id, login: $0.login, avatarUrl: $0.avatar_url, siteAdmin: $0.site_admin) }
            
            var loadMore: LoadMoreAction?
            if let link = response.response!.headers.value(for: "Link"), let url = self.nextURL(from: link) {
                loadMore = RemoteUserProfileLoader(url: url, session: session, mapper: self).load(complete:)
            }
            
            let pageProfiles = PaginatedUserProfile(
                profiles: currentProfiles + profiles,
                loadMore: loadMore
            )
            self.currentProfiles = profiles
            
            return .success(pageProfiles)
            
        } else if response.response?.statusCode == self.nonModifiedStatusCode {
            return .failure(.notModified)
            
        } else if let error = response.error {
            if error.isSessionTaskError {
                return .failure(.connectivity)
                
            } else {
                return .failure(.invalidData)
                
            }
            
        } else {
            return .failure(.unexpected)
        }
    }
    
    private func nextURL(from linkHeader: String) -> URL? {
        guard let nextLink = linkHeader.split(separator: ",").filter({ $0.contains("next") }).first else {
            return nil
        }
        
        guard let range = nextLink.range(of: "(?<=\\<).+?(?=\\>)", options: .regularExpression) else {
            return nil
        }
        
        guard let url = URL(string: String(nextLink[range])) else {
            return nil
        }
        
        return url
    }
    
}

typealias LoadUserProfileResult = Result<PaginatedUserProfile, RemoteUserProfileLoader.Error>
typealias LoadUserProfileComplete = (LoadUserProfileResult) -> Void
typealias LoadMoreAction = ((@escaping LoadUserProfileComplete) -> Void)

struct PaginatedUserProfile {
    let profiles: [UserProfile]
    let loadMore: LoadMoreAction?
    
    init(profiles: [UserProfile], loadMore: LoadMoreAction? = nil) {
        self.profiles = profiles
        self.loadMore = loadMore
    }
    
}

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
        case loaderHasDeallocated
        case unexpected
    }
    
    let url: URL
    
    let session: Session
    
    private let mapper: UserProfileMapper
    
    init(url: URL, session: Session = .default, mapper: UserProfileMapper) {
        self.url = url
        self.session = session
        self.mapper = mapper
    }
    
    func load(complete: @escaping LoadUserProfileComplete) {
        session.request(url).validate(statusCode: mapper.validStatusCodes).responseDecodable(of: [RemoteUserProfile].self) {  [weak self] response in
            
            guard let self = self else {
                complete(.failure( .loaderHasDeallocated))
                return
            }
            
            let result = self.mapper.map(response)
            
            complete(result)
        }
    }
}

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
    
    func test__loadMoreAction__request_next_url() throws {
        let link = "<https://api.github.com/user/repos?page=3&per_page=100>; rel=\"next\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\""
        let data = makeUserProfilesJSON(profiles: [])
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200, headerFields: nextLinkHeader(link: link)), error: nil)
        
        let receivedResult = assertThat(sut.load(complete:), receive: .success([]))
        let loadMoreAction = try XCTUnwrap((try? receivedResult?.get().loadMore))
        
        let nextData = makeUserProfilesJSON(profiles: [])
        sut.stub(data: nextData, response: anyHTTPURLResponse(statusCode: 200, headerFields: nil), error: nil)
        
        assertThat(loadMoreAction, request: URL(string: "https://api.github.com/user/repos?page=3&per_page=100")!)
    }
    
    func test__loadMoreAction__deliversAggregatedUserProfiles() throws {
        let (model1, json1) = makeUserProfile()
        let (model2, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        let sut = makeSUT().stub(data: data, response: anyHTTPURLResponse(statusCode: 200, headerFields: nextLinkHeader()), error: nil)
        
        let receivedResult = assertThat(sut.load(complete:), receive: .success([model1, model2]))
        let loadMoreAction = try XCTUnwrap((try? receivedResult?.get().loadMore))
        
        let (model3, json3) = makeUserProfile()
        let (model4, json4) = makeUserProfile()
        let nextData = makeUserProfilesJSON(profiles: [json3, json4])
        sut.stub(data: nextData, response: anyHTTPURLResponse(statusCode: 200, headerFields: nil), error: nil)
        
        assertThat(loadMoreAction, receive: .success([model1, model2, model3, model4]))
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
        XCTAssertEqual(receivedError as NSError?, RemoteUserProfileLoader.Error.loaderHasDeallocated as NSError?)
    }

    
    func makeSUT(url: URL? = nil) -> RemoteUserProfileLoader {
        let url = url == nil ? anyURL() : url!
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        return RemoteUserProfileLoader(url: url, session: session, mapper: UserProfileMapper(session: session))
    }
    
    //MARK: - helpers
    private func assertThat(_ loadAction: LoadMoreAction, request url: URL, httpMethod: String = "GET") {
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
    private func assertThat(_ loadAction: LoadMoreAction, receive expectedProfileResult: Result<[UserProfile], RemoteUserProfileLoader.Error>?, file: StaticString = #filePath, line: UInt = #line) -> LoadUserProfileResult? {
        let exp = expectation(description: "wait for result")
        var receivedResult: LoadUserProfileResult?
        loadAction() { result in
            exp.fulfill()
            receivedResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedProfileResult) {
            
        case (let .success(receivedPaginatedProfiles), let .success(expectedProfiles)):
            XCTAssertEqual(receivedPaginatedProfiles.profiles, expectedProfiles, file: file, line: line)
            return receivedResult
        
        case (let .failure(receivedError), let .failure(expectedError)):
            XCTAssertEqual(receivedError as NSError?, expectedError as NSError?, file: file, line: line)
            return nil
        
        default:
            XCTFail("received \(String(describing: receivedResult)), but expect \(String(describing: expectedProfileResult)) instead", file: file, line: line)
            return nil
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
    
    private func nextLinkHeader(link: String = "<https://api.github.com/user/repos?page=3&per_page=100>; rel=\"next\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\"") -> [String: String] {
        ["Link": link]
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

}

//MARK: - test doubles
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
