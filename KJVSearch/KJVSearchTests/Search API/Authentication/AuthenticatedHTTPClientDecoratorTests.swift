//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 08/11/2022.
//

import KJVSearch
import XCTest

// Stopped at 22:58... need to rethink the structure here. The decorator needs to catch the request, sign it with the token and forward it already signed. In this case, the get func from the HTTPClient builds the request and sends it, so maybe the best approach is to separate these two concerns but that will need a slightly different architecture 

class AuthenticatedHTTPClientDecorator: HTTPClient {
    
    init(decoratee: HTTPClient) {
        
    }
    
    func get(from url: URL, query: String, completion: @escaping (Result) -> Void) {
        <#code#>
    }
}

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test() {
        let token = anyToken()
        let client = HTTPClientSpy()
        let requestWithoutToken = TestRequest()
        let requestWithToken = requestWithoutToken.signed(with: token)
        let service = AuthenticationTokenManagerStub(stubbedToken: token)
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        sut.get(from: anyURL(), query: anyQuery()) { _ in
            
            
        }
        
        XCTAssertEqual(client.requests, [tokenRequest])
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, query: String, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func anyToken() -> String {
        return "any token"
    }
}
