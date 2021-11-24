//
//  ImageDataLoaderCacheDecoratorTests.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/23.
//

import XCTest
import GitHubAPI
import GitHubAPIApp
class ImageDataLoaderCacheDecoratorTests: XCTestCase {
    func test_load_dispatchLoadOnEmptyCache() {
        let url = anyURL()
        let (sut, decorateeSpy) = makeSUT()

        let _ = sut.load(url: url) { _ in }
        XCTAssertEqual(decorateeSpy.requestURLs, [url])
    }
    
    func test_loadTwice_dispatchLoadTwiceOnEmptyCache() {
        let url = anyURL()
        let (sut, decorateeSpy) = makeSUT()

        let _ = sut.load(url: url) { _ in }
        let _ = sut.load(url: url) { _ in }
        
        XCTAssertEqual(decorateeSpy.requestURLs, [url, url])
    }
    
    func test_load_deliverDataOnDecorateeSuccess() {
        let data1 = imageData(color: .red)
        let (sut, decorateeSpy) = makeSUT()

        var receivedData: Data?
        let _ = sut.load(url: anyURL()) { result in
            receivedData = try? result.get()
        }

        decorateeSpy.complete(with: data1)

        XCTAssertEqual(receivedData, data1)
    }
    
    func test_load_deliversErrorOnDecorateeError() {
        let (sut, decorateeSpy) = makeSUT()

        var receivedError: Error?
        let _ = sut.load(url: anyURL()) { result in
            receivedError = result.error
        }

        decorateeSpy.complete(with: anyNSError())
        XCTAssertEqualError(receivedError, anyNSError())
    }
    
    func test_load_deliverCachedDataOnNonEmptyCache() {
        let targetURL = URL(string: "https://target-url.com")!
        let targetColorData = imageData(color: .blue)
        let stubCache = [
            anyURL(): randomImageData(),
            targetURL: targetColorData
        ]
        
        let (sut, _) = makeSUT(stubCache: stubCache)
        
        var receivedData: Data?
        _ = sut.load(url: targetURL) { result in
            receivedData = try? result.get()
        }
        
        XCTAssertEqual(receivedData, targetColorData)
    }
    
    func test_cacheLoadedData_onDecorateeSuccess() {
        let (sut, decorateeSpy) = makeSUT()
        
        let url = anyURL()
        let _ = sut.load(url: url) { _ in }

        let imageData = imageData(color: .red)
        decorateeSpy.complete(with: imageData)

        XCTAssertEqual(sut.cachedImageData(for: url), imageData)
    }
    
    func test_doesNotChangeCache_onDecorateeFailure() {
        let stubCache = [anyURL(): whiteImageData()]
        let (sut, decorateeSpy) = makeSUT(stubCache: stubCache)
        
        let url = URL(string: "https://url-not-load-before")!
        let _ = sut.load(url: url) { _ in }
        
        decorateeSpy.complete(with: anyNSError())
        XCTAssertEqual(sut.cachedImageDatas(), [whiteImageData()])
    }
    
    func test_cancelTask_dispatchCancel() {
        let url = anyURL()
        let (sut, decorateeSpy) = makeSUT()
        
        let task = sut.load(url: url) { _ in }

        task.cancel()
        
        XCTAssertEqual(decorateeSpy.cancelURLs, [url])
    }
        
    func test_load_doesNotDeliverResultOnSutDeallocated() {
        let docoratee = DecorateeSpy()
        var sut: ImageDataLoaderCacheDecorator? = ImageDataLoaderCacheDecorator(decoratee: docoratee)
        
        var receivedResult: ImageDataLoader.Result?
        _ = sut?.load(url: anyURL(), complete: { result in
            receivedResult = result
        })
        
        sut = nil
        
        docoratee.complete(with: Data())
        XCTAssertNil(receivedResult)
    }
    
    //MARK: - helpers
    private func makeSUT(stubCache: [URL: Data] = [:]) -> (ImageDataLoaderCacheDecorator, DecorateeSpy) {
        let spy = DecorateeSpy()
        let sut = ImageDataLoaderCacheDecorator(decoratee: spy, cache: stubCache)
        return (sut, spy)
    }
    
    private func imageData(color: UIColor) -> Data {
        return UIImage.image(with: color).pngData()!
    }
    
    //MARK: - test doulbe
    private class DecorateeSpy: ImageDataLoader {
        private class DecorateeImageTask: ImageDataTask {
            private var cancelCallback: (() -> Void)?
            
            init(cancelCallback: @escaping () -> Void) {
                self.cancelCallback = cancelCallback
            }
            
            func cancel() {
                cancelCallback?()
                cancelCallback = nil
            }
        }

        private var messages: [(url: URL, completion: Complete)] = []
        
        var requestURLs: [URL] {
            messages.map { $0.url }
        }
        
        var completions: [Complete] {
            messages.map { $0.completion }
        }
        
        private(set) var cancelURLs: [URL] = []
        
        func load(url: URL, complete: @escaping Complete) -> ImageDataTask {
            messages.append((url, complete))
            return DecorateeImageTask(cancelCallback: { [weak self] in
                self?.cancelURLs.append(url)
            })
        }
        
        func complete(with data: Data, at idx: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
            guard let completion = completions[safe: idx] else {
                XCTFail("completion index out of range", file: file, line: line)
                return
            }
            
            completion(.success(data))
        }
        
        func complete(with error: Error, at idx: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
            guard let completion = completions[safe: idx] else {
                XCTFail("completion index out of range", file: file, line: line)
                return
            }
            
            completion(.failure(error))
        }
    }

}

extension ImageDataLoaderCacheDecorator {
    func cachedImageData(for url: URL) -> Data? {
        inMemoryCache[url]
    }
    
    func cachedImageDatas() -> [Data] {
        inMemoryCache.map { $0.value }
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
