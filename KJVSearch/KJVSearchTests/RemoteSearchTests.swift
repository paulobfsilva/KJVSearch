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
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 401, 402, 403, 404, 405, 406, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
        
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = Data("{\"searchSamples\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = SearchItem(
            sampleId: "sampleId",
            distance: 0.01,
            externalId: "externalId",
            data: "data")
        
        let item1JSON = [
            "sampleId": item1.sampleId,
            "distance": item1.distance,
            "externalId": item1.externalId,
            "data": item1.data
        ] as [String : Any]
        
        let item2 = SearchItem(
            sampleId: "sample_aok4uykpn8dj0204",
            distance: 0.43606346799999995,
            externalId: "2 timothy/1/14",
            data: "That good thing which was committed unto thee keep by the Holy Ghost which dwelleth in us.")

        let item2JSON = [
            "sampleId": item2.sampleId,
            "distance": item2.distance,
            "externalId": item2.externalId,
            "data": item2.data
        ] as [String : Any]
        
        let itemsJSON = [
            "searchSamples": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteSearchLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSearchLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteSearchLoader, toCompleteWith result: RemoteSearchLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteSearchLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}
