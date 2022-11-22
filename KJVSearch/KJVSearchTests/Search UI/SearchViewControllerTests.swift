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
    
    func test_loadSearchResultsCompletion_rendersSuccessfullyLoadedSearchResults() {
        let searchResult0 = makeSearchResult(sampleId: "sampleId", externalId: "externalId", distance: 0.5, data: "data")
        let searchResult1 = makeSearchResult(sampleId: "sampleId", externalId: "externalId", distance: 0.5, data: "data")
        let searchResult2 = makeSearchResult(sampleId: "sampleId", externalId: "externalId", distance: 0.5, data: "data")
        let searchResult3 = makeSearchResult(sampleId: "sampleId", externalId: "externalId", distance: 0.5, data: "data")
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        XCTAssertEqual(sut.numberOfRenderedSearchResultViews(), 0)
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsLoading(with: [searchResult0], at: 0)
        assertThat(sut, isRendering: [searchResult0])
        
        assertThat(sut, hasViewConfiguredFor: searchResult0, at: 0)
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsLoading(with: [searchResult0, searchResult1, searchResult2, searchResult3], at: 1)
        assertThat(sut, isRendering: [searchResult0, searchResult1, searchResult2, searchResult3])
    }
    
    func test_loadSearchResultsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let searchResult0 = makeSearchResult(sampleId: "sampleId", externalId: "externalId", distance: 0.5, data: "data")
        let (sut, loader) = makeSUT()
        let searchBar = UISearchBar()
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsLoading(with: [searchResult0], at: 0)
        assertThat(sut, isRendering: [searchResult0])
        
        sut.searchBarSearchButtonClicked(searchBar) { _ in }
        loader.completeSearchResultsWithError(at: 1)
        assertThat(sut, isRendering: [searchResult0])
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
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: SearchViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = SearchViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: SearchViewController, isRendering searchResults: [SearchItem], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedSearchResultViews() == searchResults.count else {
            return XCTFail("Expected \(searchResults.count) results, got \(sut.numberOfRenderedSearchResultViews()) instead", file: file, line: line)
        }
        
        searchResults.enumerated().forEach {index, result in
            assertThat(sut, hasViewConfiguredFor: result, at: index, file: file, line: line)
        }
                
    }
    
    private func assertThat(_ sut: SearchViewController, hasViewConfiguredFor results: SearchItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.searchResultsView(at: index)
        
        guard let cell = view as? SearchResultCell else {
            return XCTFail("Expected \(SearchResultCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.scriptureText, results.data, "Expected text to be \(String(describing: results.data)) for results view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.scriptureVerse, results.externalId, "Expected verse to be \(String(describing: results.externalId)) for results view at index (\(index))", file: file, line: line)
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
        
        func completeSearchResultsWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
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

private extension SearchResultCell {
    var scriptureText: String? {
        return scriptureTextLabel.text
    }
    
    var scriptureVerse: String? {
        return scriptureVerseLabel.text
    }
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
