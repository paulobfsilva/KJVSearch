//
//  SearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public typealias LoadSearchResult = Result<[SearchItem], Error>

public protocol SearchLoader {
    func load(completion: @escaping (LoadSearchResult) -> Void)
}
