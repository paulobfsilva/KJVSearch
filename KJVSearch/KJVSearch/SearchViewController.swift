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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "SearchResultCell")!
    }

}
