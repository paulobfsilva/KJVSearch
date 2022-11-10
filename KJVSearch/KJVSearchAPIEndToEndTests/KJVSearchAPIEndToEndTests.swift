//
//  KJVSearchAPIEndToEndTests.swift
//  KJVSearchAPIEndToEndTests
//
//  Created by Paulo Silva on 30/10/2022.
//

import KJVSearch
import XCTest

class KJVSearchAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETSearchResult_matchesFixedTestAccountData() {
        switch getSearchResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 10, "Expected 10 items in the test search result")
            
            items.enumerated().forEach { (index, item) in
                XCTAssertEqual(item, expectedItem(at: index), "Unexpected item values at index \(index)")
            }
        case let .failure(error):
            XCTFail("Expected search result, for \(error) instead")
        default:
            XCTFail("Expected successful search results, got no results instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getSearchResult(file: StaticString = #filePath, line: UInt = #line) -> SearchLoader.Result? {
        let tokenManager = AuthenticationTokenManager()
        let serverURL = URL(string: "https://www.nyckel.com/v0.9/functions/ieydm3vaouviuob1/search?sampleCount=10&includeData=true")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral), tokenManager: tokenManager)
        let loader = RemoteSearchLoader(url: serverURL, client: client, query: "What is the Holy Ghost")
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: SearchLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> SearchItem {
        return SearchItem(
            sampleId: sampleId(at: index),
            distance: distance(at: index),
            externalId: externalId(at: index),
            data: data(at: index))
    }
    
    private func sampleId(at index: Int) -> String {
        return [
            "sample_aok4uykpn8dj0204",
            "sample_ca9e9t8d3irjatgr",
            "sample_z9ddnxf9p0biu4zg",
            "sample_3d5e630q193847zr",
            "sample_qf6otcikqvw71xm3",
            "sample_uxtkfdfzj4tx536n",
            "sample_ef4ijyv8x6fnheme",
            "sample_aubmcnxqbm17j4xx",
            "sample_4oujzd0b4m529vvd",
            "sample_saeh0q3rqw9zxi8n"
        ][index]
    }
    
    private func distance(at index: Int) -> Double {
        return [
            0.43606346799999995,
            0.46684533399999995,
            0.488436937,
            0.49669820099999995,
            0.509973794,
            0.511964053,
            0.5191062989999999,
            0.522793531,
            0.535647482,
            0.535730898
        ][index]
    }
    
    private func externalId(at index: Int) -> String {
        return [
            "2 timothy/1/14",
            "1 thessalonians/5/19",
            "hebrews/10/15",
            "acts/19/2",
            "hebrews/3/7",
            "acts/8/15",
            "john/3/6",
            "1 corinthians/6/19",
            "acts/5/32",
            "1 corinthians/2/13"
        ][index]
    }
    
    private func data(at index: Int) -> String {
        return [
            "That good thing which was committed unto thee keep by the Holy Ghost which dwelleth in us.",
            "Quench not the Spirit.",
            "Whereof the Holy Ghost also is a witness to us: for after that he had said before,",
            "He said unto them, Have ye received the Holy Ghost since ye believed? And they said unto him, We have not so much as heard whether there be any Holy Ghost.",
            "Wherefore (as the Holy Ghost saith, To day if ye will hear his voice,",
            "Who, when they were come down, prayed for them, that they might receive the Holy Ghost:",
            "That which is born of the flesh is flesh; and that which is born of the Spirit is spirit.",
            "What? know ye not that your body is the temple of the Holy Ghost which is in you, which ye have of God, and ye are not your own?",
            "And we are his witnesses of these things; and so is also the Holy Ghost, whom God hath given to them that obey him.",
            "Which things also we speak, not in the words which man's wisdom teacheth, but which the Holy Ghost teacheth; comparing spiritual things with spiritual."
        ][index]
    }
}
