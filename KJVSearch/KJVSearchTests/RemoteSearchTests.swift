//
//  KJVSearchTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 26/10/2022.
//

import XCTest

class RemoteSearchLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a.url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class RemoteSearchTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteSearchLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteSearchLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
