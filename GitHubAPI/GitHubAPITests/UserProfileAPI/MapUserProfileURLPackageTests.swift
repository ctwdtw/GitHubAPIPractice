//
//  LoadPaginatedUserProfileFromRemoteUseCaseTests.swift
//  GitHubAPITests
//
//  Created by Paul Lee on 2021/10/27.
//

import XCTest
import GitHubAPI
import Alamofire

class MapUserProfileURLPackageTests: XCTestCase {
    func test__map__throws_connectivity_error_on_afError() {
        let response = makeDataResponse(data: nil, httpResponse: nil, error: AFError.errorForTestingPurpose)
        
        let sut = UserProfileMapper()
        
        XCTAssertThrowsError(try sut.map(response) as UserProfileURLPackage) { error in
            XCTAssertEqual(error as NSError?, UserProfileMapper.Error.connectivity as NSError?)
        }
    }
    
    func test__map__throws_invalidData_error_on_unContracted_statusCode() {
        let response = makeDataResponse(
            data: nil,
            httpResponse: anyHTTPURLResponse(statusCode: 199),
            error: nil
        )
        
        let sut = UserProfileMapper()
        
        XCTAssertThrowsError(try sut.map(response) as UserProfileURLPackage) { error in
            XCTAssertEqual(error as NSError?, UserProfileMapper.Error.invalidData as NSError?)
        }
    }
    
    func test__map__throws_invalidData_error_on_non_json() {
        let data = "any-non-json".data(using: .utf8)!
        let response = makeDataResponse(
            data: data,
            httpResponse: anyHTTPURLResponse(statusCode: 200),
            error: nil
        )
        
        let sut = UserProfileMapper()
        
        XCTAssertThrowsError(try sut.map(response) as UserProfileURLPackage) { error in
            XCTAssertEqual(error as NSError?, UserProfileMapper.Error.invalidData as NSError?)
        }
    }
    
    func test__map__throws_invalidData_error_on_unContracted_json() {
        let data = "{\"key\": \"value\"}".data(using: .utf8)!
        let response = makeDataResponse(
            data: data,
            httpResponse: anyHTTPURLResponse(statusCode: 200),
            error: nil
        )
        
        let sut = UserProfileMapper()
        
        XCTAssertThrowsError(try sut.map(response) as UserProfileURLPackage) { error in
            XCTAssertEqual(error as NSError?, UserProfileMapper.Error.invalidData as NSError?)
        }
    }
    
    func test__map__throws_nonModified_error_on_304_status_code() {
        let response = makeDataResponse(
            data: anyData(),
            httpResponse: anyHTTPURLResponse(statusCode: 304),
            error: nil
        )
        
        let sut = UserProfileMapper()
        
        XCTAssertThrowsError(try sut.map(response) as UserProfileURLPackage) { error in
            XCTAssertEqual(error as NSError?, UserProfileMapper.Error.notModified as NSError?)
        }
    }
    
    func test__map__throws_invalidData_error_on_valid_jsons_with_non_contracted_status_code() {
        let (_, json1) = makeUserProfile()
        let (_, json2) = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [json1, json2])
        
        let response = makeDataResponse(
            data: data,
            httpResponse: anyHTTPURLResponse(statusCode: 199),
            error: nil
        )
        
        let sut = UserProfileMapper()
        
        XCTAssertThrowsError(try sut.map(response) as UserProfileURLPackage) { error in
            XCTAssertEqual(error as NSError?, UserProfileMapper.Error.invalidData as NSError?)
        }
    }
    
    func test__map__delivers_nil_nextURL_on_empty_header() {
        let sut = UserProfileMapper()
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [item0.json, item1.json])
        
        let httpResponse = anyHTTPURLResponse(statusCode: 200, headerFields: nil)
        let response = makeDataResponse(data: data, httpResponse: httpResponse, error: nil)
        
        let result: UserProfileURLPackage = try! sut.map(response)
        
        XCTAssertEqual(result.userProfiles, [item0.model, item1.model])
        XCTAssertEqual(result.nextURL, nil)
    }
    
    func test__map__delivers_nil_nextURL_on_invalid_link_field() {
        let sut = UserProfileMapper()
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [item0.json, item1.json])
        
        let link = "<https://api.github.com/user/repos?page=3&per_page=100>; rel=\"nxet\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\""
        let httpResponse = anyHTTPURLResponse(statusCode: 200, headerFields: nextLinkHeader(link: link))
        let response = makeDataResponse(data: data, httpResponse: httpResponse, error: nil)
        
        let result: UserProfileURLPackage = try! sut.map(response)
        
        XCTAssertEqual(result.userProfiles, [item0.model, item1.model])
        XCTAssertEqual(result.nextURL, nil)
    }
    
    func test__map__delivers_nil_nextURL_on_invalid_url_string() {
        let sut = UserProfileMapper()
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [item0.json, item1.json])
        
        let link = "<not a url>; rel=\"next\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\""
        let httpResponse = anyHTTPURLResponse(statusCode: 200, headerFields: nextLinkHeader(link: link))
        let response = makeDataResponse(data: data, httpResponse: httpResponse, error: nil)
        
        let result: UserProfileURLPackage = try! sut.map(response)
        
        XCTAssertEqual(result.userProfiles, [item0.model, item1.model])
        XCTAssertEqual(result.nextURL, nil)
    }
    
    func test__map__delivers_nil_nextURL_on_invalid_link_pattern() {
            let sut = UserProfileMapper()
            let item0 = makeUserProfile()
            let item1 = makeUserProfile()
            let data = makeUserProfilesJSON(profiles: [item0.json, item1.json])
            
            let link = "[https://api.github.com/user/repos?page=3&per_page=100]; rel=\"next\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\""
            let httpResponse = anyHTTPURLResponse(statusCode: 200, headerFields: nextLinkHeader(link: link))
            let response = makeDataResponse(data: data, httpResponse: httpResponse, error: nil)
            
            let result: UserProfileURLPackage = try! sut.map(response)
            
            XCTAssertEqual(result.userProfiles, [item0.model, item1.model])
            XCTAssertEqual(result.nextURL, nil)
    }
    
    func test__map__nextURL_on_next_link_header() {
        let sut = UserProfileMapper()
        let item0 = makeUserProfile()
        let item1 = makeUserProfile()
        let data = makeUserProfilesJSON(profiles: [item0.json, item1.json])
        
        let link = "<https://api.github.com/user/repos?page=3&per_page=100>; rel=\"next\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\""
        let httpResponse = anyHTTPURLResponse(statusCode: 200, headerFields: nextLinkHeader(link: link))
        let response = makeDataResponse(data: data, httpResponse: httpResponse, error: nil)
        
        let result: UserProfileURLPackage = try! sut.map(response)
        
        XCTAssertEqual(result.userProfiles, [item0.model, item1.model])
        XCTAssertEqual(result.nextURL, URL(string: "https://api.github.com/user/repos?page=3&per_page=100")!)
    }
    
    private func nextLinkHeader(link: String = "<https://api.github.com/user/repos?page=3&per_page=100>; rel=\"next\", <https://api.github.com/user/repos?page=50&per_page=100>; rel=\"last\"") -> [String: String] {
        ["Link": link]
    }
    
    private func makeDataResponse(data: Data? = nil, httpResponse: HTTPURLResponse? = nil, error: AFError? = nil) -> DataResponse<Data, AFError> {
        var result: Result<Data, AFError>!
        
        if let data = data {
            result = .success(data)
            
        } else if let error = error {
            
            result = .failure(error)
        
        } else {
            result = .failure(AFError.errorForTestingPurpose)
            
        }
        
        return DataResponse(
            request: nil,
            response: httpResponse,
            data: data,
            metrics: nil,
            serializationDuration: 0,
            result: result
        )
        
    }
}

private extension AFError {
    static var errorForTestingPurpose: AFError {
        AFError.sessionTaskFailed(error: anyNSError())
    }
}
