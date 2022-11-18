//
//  SearchViewControllerTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 12/11/2022.
//

import KJVSearch
import UIKit
import XCTest

final class SearchViewController: UITableViewController, UISearchBarDelegate {
    private var loader: SearchLoader?
    private var queryText: String = ""
    private var searchResults = [SearchItem]()
    
    convenience init(loader: SearchLoader) {
        self.init()
        self.loader = loader
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar, completion: @escaping (Bool) -> Void) {
        searchBar.resignFirstResponder()
        queryText = searchBar.text ?? ""
        loader?.loadSearch(query: queryText, limit: 10) { [weak self] results in
            switch results {
            case let .success(arrayOfResults):
                self?.searchResults = arrayOfResults
                self?.tableView.reloadData()
                completion(true)
            case let .failure(error):
                print("\(error)")
                completion(false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.searchResults.count - 1 {
            self.loadMore()
        }
        let cellModel = searchResults[indexPath.row]
        let cell = SearchResultCellProduction()
        cell.scriptureVerseLabel.text = cellModel.externalId
        cell.scriptureTextLabel.text = cellModel.data
        return cell
    }
    
    private func loadMore() {
        loader?.loadSearch(query: queryText, limit: searchResults.count + 10) {_ in}
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
