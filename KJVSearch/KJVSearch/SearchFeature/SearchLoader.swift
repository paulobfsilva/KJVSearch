//
//  SearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public enum LoadSearchResult<Error: Swift.Error> {
    case success([SearchItem])
    case failure(Error)
}

protocol SearchLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadSearchResult<Error>) -> Void)
}
