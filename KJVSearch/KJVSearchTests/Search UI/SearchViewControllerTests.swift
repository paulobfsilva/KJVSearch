//
//  SearchViewControllerTests.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 12/11/2022.
//

import KJVSearch
import UIKit
import XCTest

final class SearchViewControllerProduction: UITableViewController, UISearchBarDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! SearchResultCell
        _ = searchResults[indexPath.row]
        //cell.configure(with: model)
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
        
        func loadSearch(query: String, limit: Int = 10, completion: @escaping (SearchLoader.Result) -> Void) {
            loadCallCount += 1
            completion(.success([
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: ""),
                SearchItem(sampleId: "", distance: 0.5, externalId: "", data: "")
            ]))
        }
    }

}
