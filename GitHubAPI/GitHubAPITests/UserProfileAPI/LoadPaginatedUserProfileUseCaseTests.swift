//
//  LoadPaginatedUserProfileUseCaseTests.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/27.
//

import XCTest
import GitHubAPI
import Alamofire

class LoadPaginatedUserProfileUseCaseTests: XCTestCase {
    func test__sut__can_init() {
        let url = anyURL()
        let _ = makeSUT(url: url)
    }
    
    func test__load__requestURL() {
        let url = anyURL()
        let sut = makeSUT(url: url)
        assertThat( { sut.load { _ in } }, request: url, httpMethod: "GET")
    }
    
    func test__load__delivers_error_onErrorMapper() {
        let url = anyURL()
        let sut = makeSUT(url: url) { _ in
            throw anyNSError()
        }
        
        let error = errorFor(sut.load(complete:)) as NSError?
        XCTAssertEqual(error, anyNSError())
    }
    
    func test__loadMore_requestNextURL() throws {
        let nextURL = URL(string: "https://next-url.com")!
        let stubMapper = StubMapper().stubPackage(UserProfileURLPackage([makeUserProfile().model, makeUserProfile().model], nextURL: nextURL))

        let sut = makeSUT(url: anyURL(), mapping: stubMapper.map(_:))
        let loadMore = try XCTUnwrap(pageFor(sut.load(complete:))?.loadMore)
        assertThat( { loadMore() { _ in } }, request: nextURL)
    }
    
    func test__loadOneMore_requestNextNextURL() throws {
        // load
        let nextURL = URL(string: "https://next-url.com")!
        let stubMapper = StubMapper().stubPackage(UserProfileURLPackage([makeUserProfile().model, makeUserProfile().model], nextURL: nextURL))
        let sut = makeSUT(url: anyURL(), mapping: stubMapper.map(_:))
        let loadMore = try XCTUnwrap(pageFor(sut.load(complete:))?.loadMore)
        
        // load more
        let nextNextURL = URL(string: "https://next-next--url.com")!
        stubMapper.stubPackage(UserProfileURLPackage([makeUserProfile().model], nextURL: nextNextURL))
        let loadOneMore = try XCTUnwrap(pageFor(loadMore)?.loadMore)
        
        // load one more
        assertThat( { loadOneMore { _ in } } , request: nextNextURL)
    }
    
    func test__loadMore__delivers_paginatedUserProfiles() throws {
        // load first page
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let nextURL = URL(string: "https://next-url.com")!
        let stubMapper = StubMapper().stubPackage(UserProfileURLPackage([item0.model, item1.model], nextURL: nextURL))
        
        let sut = makeSUT(url: anyURL(), mapping: stubMapper.map(_:))
        let page = try XCTUnwrap(pageFor(sut.load(complete:)))
        XCTAssertEqual(page.userProfiles, [item0.model, item1.model])
        
        // load next page
        let item3 = makeUserProfile()
        let item4 = makeUserProfile()
        let nextNextURL = URL(string: "https://next-next-url.com")
        stubMapper.stubPackage(UserProfileURLPackage([item3.model, item4.model], nextURL: nextNextURL))
        
        let loadMore = try XCTUnwrap(page.loadMore)
        let nextPage = try XCTUnwrap(pageFor(loadMore))
        XCTAssertEqual(nextPage.userProfiles, [item0.model, item1.model, item3.model, item4.model])
        
        // load next next page failure
        stubMapper.stubError(anyNSError())
        let loadOneMore = try XCTUnwrap(nextPage.loadMore)
        let error = errorFor(loadOneMore) as NSError?
        XCTAssertEqual(error, anyNSError())
        
        // load next next page success
        let item5 = makeUserProfile()
        let item6 = makeUserProfile()
        stubMapper.stubPackage(UserProfileURLPackage([item5.model, item6.model], nextURL: nil))
        let nextNextPage = try XCTUnwrap(pageFor(loadOneMore))
        XCTAssertEqual(nextNextPage.userProfiles, [item0.model, item1.model, item3.model, item4.model, item5.model, item6.model])
    }
     
    private class StubMapper: URLPackageMapping {
        private var stubbedResult: Result<UserProfileURLPackage, Error> = .failure(anyNSError())
        
        func map(_ response: DataResponse<Data, AFError>) throws -> UserProfileURLPackage {
            try stubbedResult.get()
        }
        
        @discardableResult
        func stubError(_ error: Error) -> StubMapper {
            stubbedResult = .failure(error)
            return self
        }
        
        @discardableResult
        func stubPackage(_ package: UserProfileURLPackage) -> StubMapper {
            stubbedResult = .success(package)
            return self
        }
    }
    
    private func makeSUT(url: URL, mapping: @escaping URLPackageMapping.URLPackageMapping = UserProfileMapper().map(_:)) -> PaginatedRemoteUserProfileLoader {
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        
        return PaginatedRemoteUserProfileLoader(url: url, session: session, mapping: mapping)
    }
    
    private func assertThat(_ loadAction: () -> Void, request url: URL, httpMethod: String = "GET", file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for request")
        
        var observedRequest: URLRequest?
        URLProtocolStub.requestObserver = { request in
            exp.fulfill()
            observedRequest = request
        }
        
        loadAction()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observedRequest?.url, url, file: file, line: line)
        XCTAssertEqual(observedRequest?.httpMethod, httpMethod, file: file, line: line)
    }
    
    private typealias LoadAction = ((@escaping PaginatedUserProfile.Complete) -> Void)
    private func pageFor(_ loadAction: LoadAction, file: StaticString = #filePath, line: UInt = #line) -> PaginatedUserProfile? {
        let exp = expectation(description: "wait for result")
        var receivedResult: PaginatedUserProfile.Result?
        loadAction() { result in
            exp.fulfill()
            receivedResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return try? receivedResult?.get()
    }
    
    private func errorFor(_ loadAction: LoadAction, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for result")
        var receivedResult: PaginatedUserProfile.Result?
        loadAction() { result in
            exp.fulfill()
            receivedResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult?.error
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
