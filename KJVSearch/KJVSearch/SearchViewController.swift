//
//  SearchViewController.swift
//  KJVSearch
//
//  Created by Paulo Silva on 11/11/2022.
//

import UIKit

struct SearchResultsViewModel {
    let distance: Double
    let scripture: String
    let text: String
}

final class SearchViewController: UITableViewController {
    private let searchResults = SearchResultsViewModel.prototypeResults
    
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
