//
//  SearchViewControllerTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 12/11/2022.
//

import KJVSearch
import UIKit
import XCTest

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

        sut.searchBarSearchButtonClicked(searchBar) { result in
            
        }
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_multipleSearchButtonTaps_produceMultipleLoads() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()

        sut.searchBarSearchButtonClicked(searchBar) { result in }
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.searchBarSearchButtonClicked(searchBar) { result in }
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.searchBarSearchButtonClicked(searchBar) { result in }
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_pullToRefresh_loadsSearchResults() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_searchButtonTapped_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_searchButtonIsTapped_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_pullToRefresh_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_pullToRefresh_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.refreshControl?.simulatePullToRefresh()
        loader.completeSearchResultsLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_searchButtonIsTapped_expectTableViewToHaveDefaultNumberOfRows() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsLoading()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_scrollToEndOfTable_loadsMoreItems() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsLoading(at: 0)
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsLoading(at: 1)

        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
//    func test_loadSearchResultsCompletion_rendersSuccessfullyLoadedSearchResults() {
//        let searchResult0 = makeSearchResult(
//            sampleId: "sampleId",
//            externalId: "externalId",
//            distance: 0.5,
//            data: "A text for a verse"
//        )
//        let searchBar = UISearchBar()
//        let (sut, loader) = makeSUT()
//
//        sut.loadViewIfNeeded()
//
//        XCTAssertEqual(sut.numberOfRenderedSearchResultViews(), 0)
//
//        sut.searchBarSearchButtonClicked(searchBar) { _ in }
//
//        loader.completeSearchResultsLoading(with: [searchResult0], at:0)
//        XCTAssertEqual(sut.numberOfRenderedSearchResultViews(), 1)
//
////        let view = sut.searchResultsView(at: 0) as? SearchResultCellProduction
////        XCTAssertNotNil(view)
////        XCTAssertEqual(view?.scriptureText, searchResult0.data)
////        XCTAssertEqual(view?.scriptureVerse, searchResult0.externalId)
////
//    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: SearchViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = SearchViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func makeSearchResult(sampleId: String, externalId: String, distance: Double, data: String) -> SearchItem {
        return SearchItem(sampleId: sampleId, distance: distance, externalId: externalId, data: data)
    }
    
    class LoaderSpy: SearchLoader {
        private var completions = [(SearchLoader.Result) -> Void]()
        var loadCallCount: Int {
            return completions.count
        }
        
        func loadSearch(query: String, limit: Int = 10, completion: @escaping (SearchLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeSearchResultsLoading(with results: [SearchItem] = [], at index: Int = 0) {
            completions[index](.success(results))
        }
    }

}

private extension SearchViewController {
    func numberOfRenderedSearchResultViews() -> Int {
        return tableView.numberOfRows(inSection: searchResultsSection)
    }
    
    private var searchResultsSection: Int {
        return 0
    }
    
    func searchResultsView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: searchResultsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

private extension SearchResultCellProduction {
    var scriptureText: String? {
        return scriptureTextLabel.text
    }
    
    var scriptureVerse: String? {
        return scriptureVerseLabel.text
    }
}

class SearchResultCellProduction: UITableViewCell {
    public var scriptureTextLabel: UILabel!
    public var scriptureVerseLabel: UILabel!
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0))
            }
        }
    }
}
