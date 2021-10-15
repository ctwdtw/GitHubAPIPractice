//
//  CombinePlayground.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/15.
//

import XCTest
import Combine
import GitHubAPI
import Alamofire

class CombinePlayground: XCTestCase {
    lazy var session: Session = {
        let config = URLSessionConfiguration.af.default
        config.protocolClasses = [URLProtocolStub.self] + (config.protocolClasses ?? [])
        return Session(configuration: config)
    }()
    
    
    lazy var loader: RemoteUserProfileLoader = {
        RemoteUserProfileLoader(url: anyURL(), session: session, mapper: UserProfileMapper())
    }()
    
    func test__future__emit_value_upon_creation() {
        let exp = expectation(description: "wait for value")
        
        var emitValueUponCreation = false
        let _ = Future<Int, Never> { promise in
            exp.fulfill()
            emitValueUponCreation = true
            promise(.success(1))
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(emitValueUponCreation)
    }
    
    func test__defer__does_not_emit_value_upon_creation() throws {
        throw XCTSkip("we know the concept, now we skip this test case and keep the code as an illustration on how combine behave.")
        let exp = expectation(description: "exp not fulfill")
        exp.isInverted = true
        
        var emitValueUponCreation = false
        let _ = Deferred {
            Future<Int, Never> { promise in
                exp.fulfill()
                emitValueUponCreation = true
                promise(.success(1))
            }
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertFalse(emitValueUponCreation) // 一秒內沒有 fulfill 就算測試通過
    }
    
    func test__defer__emit_value_when_subscribed() {
        let exp = expectation(description: "wait for value")
        var valueHasEmitted = false
        var resultValue: Int?
        let _ = Deferred {
            Future<Int, Never> { promise in
                exp.fulfill()
                promise(.success(1))
                valueHasEmitted = true
            }
        }.sink { value in
            resultValue = value
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(valueHasEmitted)
        XCTAssertEqual(resultValue, 1)
    }
    
    func test_convert_loader_to_publisher() {
        let publisher = loader.publisher().stub(data: nil, response: anyHTTPURLResponse(statusCode: 401), error: nil)
        
        let exp = expectation(description: "wait for complete")
        
        var disposalBag = Set<AnyCancellable>()
        
        var receivedError: Error?
        publisher.sink { complete in
            exp.fulfill()
            switch complete {
            case .finished:
                break
            case .failure(let error):
                receivedError = error
            }
            
        } receiveValue: { profiles in
            // nothing
        }.store(in: &disposalBag)

        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, UserProfileMapper.Error.invalidData as NSError?)
    }
}

extension RemoteUserProfileLoader {
    func publisher() -> AnyPublisher<[UserProfile], UserProfileMapper.Error> {
        return Deferred {
            Future<[UserProfile], UserProfileMapper.Error>(self.load(complete:))
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [UserProfile], Failure == UserProfileMapper.Error {
    @discardableResult
    func stub(data: Data?, response: HTTPURLResponse?, error: Swift.Error?) -> Self {
        URLProtocolStub.stub(data: data, response: response, error: error)
        return self
    }
}


