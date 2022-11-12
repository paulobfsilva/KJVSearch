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
        let loader = LoaderSpy()
        _ = SearchViewControllerProduction(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_doesNotLoadSearchResults() {
        let loader = LoaderSpy()
        let sut = SearchViewControllerProduction(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_searchButtonIsTapped_loadsSearchResults() {
        let loader = LoaderSpy()
        let sut = SearchViewControllerProduction(loader: loader)
        let searchBar = UISearchBar()

        sut.searchBarSearchButtonClicked(searchBar)
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    class LoaderSpy: SearchLoader {
        
        private(set) var loadCallCount: Int = 0
        
        func loadSearch(query: String, completion: @escaping (SearchLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }

}
