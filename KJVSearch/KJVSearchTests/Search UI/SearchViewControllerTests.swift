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

    func test_loadSearchResultsActions_requestSearchResultsFromLoader() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests once the view is loaded")

        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once the search bar button is tapped")

        sut.searchBarSearchButtonClicked(searchBar) { result in }
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once the user taps the search button again")
        
        sut.searchBarSearchButtonClicked(searchBar) { result in }
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once the user initiates another load")

    }
    
    func test_pullToRefresh_loadsSearchResults() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        
        sut.simulateUserInitiatedRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingSearchResultsIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once the search bar button is tapped")
        
        loader.completeSearchResultsLoading(at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedRefresh()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiated a reload")
        
        loader.completeSearchResultsLoading(at: 1)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
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

private extension SearchViewController {
    func simulateUserInitiatedRefresh() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0))
            }
        }
    }
}
