//
//  KJVSearchTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 26/10/2022.
//

import KJVSearch
import XCTest

class RemoteSearchTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadSearch(query: anyQuery()) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadSearch(query: anyQuery()) { _ in }
        sut.loadSearch(query: anyQuery()) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 401, 402, 403, 404, 405, 406, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
        
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            sampleId: "sampleId",
            distance: 0.01,
            externalId: "externalId",
            text: "data")
        
        let item2 = makeItem(
            sampleId: "sample_aok4uykpn8dj0204",
            distance: 0.43606346799999995,
            externalId: "2 timothy/1/14",
            text: "That good thing which was committed unto thee keep by the Holy Ghost which dwelleth in us.")
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultAdterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        let query = "What is the Holy Ghost"
        var sut: RemoteSearchLoader? = RemoteSearchLoader(url: url, client: client, query: query)
        
        var capturedResults = [RemoteSearchLoader.Result]()
        sut?.loadSearch(query: anyQuery()) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, query: String = "What is the Holy Ghost", file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteSearchLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSearchLoader(url: url, client: client, query: query)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteSearchLoader.Error) -> RemoteSearchLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(sampleId: String, distance: Double, externalId: String, text: String) -> (model: SearchItem, json: [String: Any]) {
        let item = SearchItem(sampleId: sampleId, distance: distance, externalId: externalId, data: text)
        let json = [
            "sampleId": sampleId,
            "distance": distance,
            "externalId": externalId,
            "data": text
        ].compactMapValues { $0 }
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["searchSamples": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteSearchLoader, toCompleteWith expectedResult: RemoteSearchLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.loadSearch(query: anyQuery()) { receivedResult in
            // unwrap the different error types for both Search API and Search Feature Modules
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteSearchLoader.Error), .failure(expectedError as RemoteSearchLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
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
}
