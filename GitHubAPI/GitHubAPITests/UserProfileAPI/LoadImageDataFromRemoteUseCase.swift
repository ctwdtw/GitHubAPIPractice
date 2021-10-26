//
//  LoadImageDataFromRemoteUseCase.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/24.
//

import XCTest
import Alamofire

protocol ImageDataTask {
    func cancel()
}

class RemoteImageDataLoader {
    class RemoteImageDataTask: ImageDataTask {
        var request: DataRequest?
        private var completion: Complete?
        
        init(complete: @escaping Complete) {
            self.completion = complete
        }
        
        func cancel() {
            request?.cancel()
            completion = nil
        }
        
        func complete(with result: Result) {
            completion?(result)
        }
        
    }
    
    typealias Result = Swift.Result<Data, Error>
    
    typealias Complete = (Result) -> Void
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    @discardableResult
    func load(url: URL, complete: @escaping Complete) -> ImageDataTask {
        let task = RemoteImageDataTask(complete: complete)
        
        let request = session.request(url).responseData { [weak self] response in
            guard self != nil else {
                return
            }
            
            guard let statusCode = response.response?.statusCode else {
                task.complete(with: .failure(.connectivity))
                return
            }
            
            guard statusCode == 200 else {
                task.complete(with: .failure(.invalidData))
                return
            }
            
            guard let data = response.data else {
                task.complete(with: .failure(.invalidData))
                return
            }
            
            task.complete(with: .success(data))
        }
        
        task.request = request
        
        return task
        
    }
}

class LoadImageDataFromRemoteUseCase: XCTestCase {
    func test__load__request_URL() {
        let sut: RemoteImageDataLoader = makeSUT()
        let exp = expectation(description: "wait for request")

        var observedRequest: URLRequest?
        URLProtocolStub.requestObserver = { request in
            exp.fulfill()
            observedRequest = request
        }

        let url = anyURL()
        sut.load(url: url) { _ in }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(observedRequest?.url, url)
    }

    func test__load__delivers_connectivity_error_on_stubbed_error() {
        let sut = makeSUT().stub(data: nil, response: nil, error: anyNSError())

        assertThat(sut, loadToReceive: .failure(.connectivity))
    }

    func test__load__delivers_invalidData_error_on_non_200_status_code() {
        let sut = makeSUT().stub(data: anyData(), response: anyHTTPURLResponse(statusCode: 199), error: nil)

        assertThat(sut, loadToReceive: .failure(.invalidData))
    }

    func test__load__delivers_invalidData_error_on_200_status_code_but_nil_image_data() {
        let sut = makeSUT().stub(data: nil, response: anyHTTPURLResponse(statusCode: 200), error: nil)

        assertThat(sut, loadToReceive: .failure(.invalidData))
    }

    func test__load__delivers_invalidData_error_on_200_status_code_but_empty_image_data() {
        let sut = makeSUT().stub(data: Data(), response: anyHTTPURLResponse(statusCode: 200), error: nil)

        assertThat(sut, loadToReceive: .failure(.invalidData))
    }

    func test__load__delivers_data_on_200_status_code() {
        let data = anyData()
        let sut = makeSUT().stub(data: anyData(), response: anyHTTPURLResponse(statusCode: 200), error: nil)

        assertThat(sut, loadToReceive: .success(data))
    }
    
    func test__load__can_cancel_imageLoadingTask() {
        let (sut, eventMonitor) = makeSUT()

        let createExp = expectation(description: "wait for create")
        
        eventMonitor.createInitialRequestObserver = { _ in
            createExp.fulfill()
        }
        
        let cancelExp = expectation(description: "wait for cancel")

        var cancelledRequest: URLRequest?
        eventMonitor.cancelledRequestObserver = { request in
            cancelExp.fulfill()
            cancelledRequest = request
        }

        let imageURL = anyURL()
        let task = sut.load(url: imageURL) { _ in }
        
        wait(for: [createExp], timeout: 1.0)
    
        task.cancel()
        
        wait(for: [cancelExp], timeout: 1.0)
        XCTAssertEqual(cancelledRequest?.url, imageURL)
    }
    
    func test__load__does_not_complete_when_ImageLoadingTask_is_cancelled() {
        let (sut, eventMonitor) = makeSUT()

        let createExp = expectation(description: "wait for create")
        eventMonitor.createInitialRequestObserver = { _ in
            createExp.fulfill()
        }
        
        let cancelExp = expectation(description: "wait for cancel")
        eventMonitor.cancelledRequestObserver = { request in
            cancelExp.fulfill()
        }

        let task = sut.load(url: anyURL()) { _ in }
        
        wait(for: [createExp], timeout: 1.0)
        XCTAssertEqual((task as? RemoteImageDataLoader.RemoteImageDataTask)?.canComplete, true)
        
        task.cancel()
        
        wait(for: [cancelExp], timeout: 1.0)
        XCTAssertEqual((task as? RemoteImageDataLoader.RemoteImageDataTask)?.canComplete, false)
    }
    
    private func makeSUT() -> RemoteImageDataLoader {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let session = Session(configuration: config)
        return RemoteImageDataLoader(session: session)
    }
    
    private func assertThat(_ sut: RemoteImageDataLoader, loadToReceive expectedResult: RemoteImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for complete")
        
        let url = anyURL()
        
        var receivedResult: RemoteImageDataLoader.Result?
        sut.load(url: url) { result in
            exp.fulfill()
            receivedResult = result
        }
        
        wait(for: [exp], timeout: 1.0)
        
        switch (receivedResult, expectedResult) {
            
        case (.success(let receivedData), .success(let expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            break
        
        case (.failure(let receivedError), .failure(let expectedError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            break
        
        default:
            XCTFail("receive \(String(describing: receivedResult)), but expect \(expectedResult)", file: file, line: line)
        }
    }
    
    private func makeSUT() -> (RemoteImageDataLoader, SpyEventMonitor) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        let spyEventMonitor = SpyEventMonitor()
        let session = Session(configuration: config, eventMonitors: [spyEventMonitor])
        return (RemoteImageDataLoader(session: session), spyEventMonitor)
    }
    
    private class SpyEventMonitor: EventMonitor {
        var cancelledRequestObserver: ((URLRequest) -> Void)?
        func requestDidCancel(_ request: Request) {
            if let rq = request.request {
                cancelledRequestObserver?(rq)
            } else {
               XCTFail("nil-request")
            }
        }
        
        var createInitialRequestObserver: ((URLRequest) -> Void)?
        func request(_ request: Request, didCreateInitialURLRequest urlRequest: URLRequest) {
            createInitialRequestObserver?(urlRequest)
        }
        
        func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
            print("did parse response")
        }
        
    }
}

private extension RemoteImageDataLoader {
    @discardableResult
    func stub(data: Data?, response: HTTPURLResponse?, error: Swift.Error?) -> RemoteImageDataLoader {
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

private extension RemoteImageDataLoader.RemoteImageDataTask {
    var canComplete: Bool {
        return !(self.completion == nil)
    }
}
