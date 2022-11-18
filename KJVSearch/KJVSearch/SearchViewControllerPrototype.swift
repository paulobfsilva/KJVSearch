//
//  SearchViewController.swift
//  KJVSearch
//
//  Created by Paulo Silva on 11/11/2022.
//

import UIKit

public struct SearchResultsViewModel {
    let distance: Double
    let scripture: String
    let text: String
}

final class SearchViewControllerPrototype: UITableViewController {
    private var searchResults = [SearchResultsViewModel]()
    private var queryText: String = ""
    
    @IBOutlet private(set) var searchBar: UISearchBar!
    @IBOutlet private(set) var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        if let searchTextField = self.searchBar.value(forKey: "searchField") as? UITextField , let clearButton = searchTextField.value(forKey: "_clearButton")as? UIButton {

             clearButton.addTarget(self, action: #selector(self.didTapClearButton), for: .touchUpInside)
        }
    }
    
    @objc private func didTapClearButton() {
        queryText = searchBar.text ?? ""
        print("Query text: \(queryText)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: animated)
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)  {
            if self.searchResults.isEmpty {
                self.searchResults = SearchResultsViewModel.prototypeResults
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! SearchResultCell
        let model = searchResults[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension SearchResultCell {
    func configure(with model: SearchResultsViewModel) {
        percentageImage.image = UIImage(systemName: "percent")
        scriptureVerseLabel.text = model.scripture
        fadeIn(model.text)
    }
}

extension SearchViewControllerPrototype: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        queryText = searchBar.text ?? ""
        print("Query text: \(queryText)")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        queryText = ""
        print("Query text: \(queryText)")
    }
}
