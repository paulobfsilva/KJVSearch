//
//  KJVSearchTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 26/10/2022.
//

import XCTest

class RemoteSearchLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteSearchTests: XCTestCase {
    func test_init() {
        let client = HTTPClient()
        _ = RemoteSearchLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
