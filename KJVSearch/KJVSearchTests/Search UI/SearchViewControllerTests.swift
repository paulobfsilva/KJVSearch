//
//  SearchViewControllerTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 12/11/2022.
//

import KJVSearch
import UIKit
import XCTest

final class SearchViewControllerProduction: UIViewController, UISearchBarDelegate {
    private var loader: SearchLoader?
    private var queryText: String = ""
    
    convenience init(loader: SearchLoader) {
        self.init()
        self.loader = loader
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        queryText = searchBar.text ?? ""
        loader?.loadSearch(query: queryText) { _ in }
    }
    
}

final class SearchViewControllerTests: XCTestCase {

    func test_init_doesNotLoadSearchResults() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_doesNotLoadSearchResults() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_searchButtonIsTapped_loadsSearchResults() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()

        sut.searchBarSearchButtonClicked(searchBar)
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: SearchViewControllerProduction, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = SearchViewControllerProduction(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class LoaderSpy: SearchLoader {
        
        private(set) var loadCallCount: Int = 0
        
        func loadSearch(query: String, completion: @escaping (SearchLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }

}
