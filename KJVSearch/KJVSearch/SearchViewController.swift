//
//  SearchViewController.swift
//  KJVSearch
//
//  Created by Paulo Silva on 20/11/2022.
//

import UIKit

public final class SearchViewController: UITableViewController, UISearchBarDelegate {
    private var loader: SearchLoader?
    private var queryText: String = ""
    private var searchResults = [SearchItem]()
    
    public convenience init(loader: SearchLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.loadSearch(query: queryText, limit: 10) { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar, completion: @escaping (Bool) -> Void) {
        refreshControl?.beginRefreshing()
        searchBar.resignFirstResponder()
        queryText = searchBar.text ?? ""
        loader?.loadSearch(query: queryText, limit: 10) { [weak self] results in
            self?.refreshControl?.endRefreshing()
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
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.searchResults.count - 1 {
            self.loadMore()
        }
        let cellModel = searchResults[indexPath.row]
        let cell = SearchResultCell()
        cell.scriptureVerseLabel.text = cellModel.externalId
        cell.scriptureTextLabel.text = cellModel.data
        return cell
    }
    
    private func loadMore() {
        loader?.loadSearch(query: queryText, limit: searchResults.count + 10) {_ in}
    }
    
}
