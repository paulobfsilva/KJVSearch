//
//  SearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public enum LoadSearchResult {
    case success([SearchItem])
    case failure(Error)
}

public protocol SearchLoader {
    func load(completion: @escaping (LoadSearchResult) -> Void)
}
