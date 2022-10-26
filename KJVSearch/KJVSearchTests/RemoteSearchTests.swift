//
//  KJVSearchTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 26/10/2022.
//

import XCTest

class RemoteSearchLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a.url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    
    var requestedURL: URL?
}

class RemoteSearchTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteSearchLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteSearchLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
