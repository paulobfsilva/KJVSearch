//
//  CacheSearchUseCaseTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 02/11/2022.
//

import KJVSearch
import XCTest

class LocalSearchLoader {
    private let store: SearchStore
    
    init(store: SearchStore) {
        self.store = store
    }
    
    func save(_ items: [SearchItem]) {
        store.deleteCachedSearch()
    }
}

class SearchStore {
    var deleteCachedSearchCallCount = 0
    
    func deleteCachedSearch() {
        deleteCachedSearchCallCount += 1
    }
}

class CacheSearchUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedSearchCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        XCTAssertEqual(store.deleteCachedSearchCallCount, 1)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalSearchLoader, store: SearchStore) {
        let store = SearchStore()
        let sut = LocalSearchLoader(store: store)
        return (sut, store)
    }
    
    private func uniqueItem() -> SearchItem {
        // sampleId is what makes a SearchItem unique
        return SearchItem(sampleId: UUID().uuidString, distance: 0.5, externalId: "externalId", data: "data")
    }
    
}
