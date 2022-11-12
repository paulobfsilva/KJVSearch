//
//  SearchViewControllerTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 12/11/2022.
//

import KJVSearch
import XCTest

final class SearchViewControllerProduction {
    init(loader: SearchViewControllerTests.LoaderSpy) {
        
    }
}

final class SearchViewControllerTests: XCTestCase {

    func test_init_doesNotLoadSearchResults() {
        let loader = LoaderSpy()
        _ = SearchViewControllerProduction(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }

}
