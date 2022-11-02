//
//  CacheSearchUseCaseTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 02/11/2022.
//

import XCTest

class LocalSearchLoader {
    init(store: SearchStore) {}
}

class SearchStore {
    var deleteCachedSearchCallCount = 0
}

class CacheSearchUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = SearchStore()
        _ = LocalSearchLoader(store: store)
        XCTAssertEqual(store.deleteCachedSearchCallCount, 0)
    }

}
