//
//  PaginatedAdapterTests.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/14.
//

import XCTest
import GitHubAPI
import Alamofire

typealias PaginatedUserProfileResult = Result<PaginatedUserProfile, RemoteUserProfileLoader.Error>
typealias PaginatedLoadUserProfileComplete = (PaginatedUserProfileResult) -> Void
typealias PaginatedLoadMoreAction = ((@escaping PaginatedLoadUserProfileComplete) -> Void)

struct PaginatedUserProfile {
    let profiles: [UserProfile]
    let loadMore: PaginatedLoadMoreAction?
    
    init(profiles: [UserProfile], loadMore: PaginatedLoadMoreAction? = nil) {
        self.profiles = profiles
        self.loadMore = loadMore
    }
    
}

class PaginatedAdapter {
    private let adaptee: RemoteUserProfileLoader
    
    private var currentProfiles: [UserProfile]
    
    init(adaptee: RemoteUserProfileLoader, currentProfiles: [UserProfile]) {
        self.adaptee = adaptee
        self.currentProfiles = currentProfiles
    }
    
    func load(complete: @escaping PaginatedLoadUserProfileComplete) {
        adaptee.load { [adaptee] result in
            let page: PaginatedUserProfileResult = result.map { profiles in
                
                self.currentProfiles += profiles
                
                var loadMore: PaginatedLoadMoreAction?
                
                if let link = adaptee.mapper.currentHeaders?.value(for: "Link"), let url = self.nextURL(from: link) {
                    let loader = RemoteUserProfileLoader(url: url, session: adaptee.session, mapper: adaptee.mapper)
                    loadMore = PaginatedAdapter(adaptee: loader, currentProfiles: self.currentProfiles).load(complete:)
                }
                
                let pageProfiles = PaginatedUserProfile(
                    profiles: self.currentProfiles,
                    loadMore: loadMore
                )
                
                return pageProfiles
                
            }
            
            complete(page)
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

class PaginatedAdapterTests: XCTestCase {
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

    private func nextLinkHeader(link: String = "<https://api.github.com/user/repos?page=3&per_page=100>; rel=\"next\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\"") -> [String: String] {
        ["Link": link]
    }
    
    private func makeSUT(url: URL? = nil) -> PaginatedAdapter {
        let url = url == nil ? anyURL() : url!
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        let loader = RemoteUserProfileLoader(url: url, session: session, mapper: UserProfileMapper())
        let sut = PaginatedAdapter(adaptee: loader, currentProfiles: [])
        return sut
    }
    
    //MARK: - helpers
    private func assertThat(_ loadAction: PaginatedLoadMoreAction, request url: URL, httpMethod: String = "GET") {
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
    private func assertThat(_ loadAction: PaginatedLoadMoreAction, receive expectedResult: LoadUserProfileResult, file: StaticString = #filePath, line: UInt = #line) -> PaginatedUserProfileResult? {
        let exp = expectation(description: "wait for result")
        var receivedResult: PaginatedUserProfileResult?
        loadAction() { result in
            exp.fulfill()
            receivedResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedResult) {
            
        case (let .success(receivedProfiles), let .success(expectedProfiles)):
            XCTAssertEqual(receivedProfiles.profiles, expectedProfiles, file: file, line: line)
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

private extension PaginatedAdapter {
    @discardableResult
    func stub(data: Data?, response: HTTPURLResponse?, error: Swift.Error?) -> PaginatedAdapter {
        URLProtocolStub.stub(data: data, response: response, error: error)
        return self
    }
}
