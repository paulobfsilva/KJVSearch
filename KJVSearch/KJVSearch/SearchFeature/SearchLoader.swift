//
//  SearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

enum LoadSearchResult {
    case success([SearchItem])
    case error(Error)
}

protocol SearchLoader {
    func load(completion: @escaping (LoadSearchResult) -> Void)
}
