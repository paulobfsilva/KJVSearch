//
//  SearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public protocol SearchLoader {
    typealias Result = Swift.Result<[SearchItem], Error>

    func loadSearch(query: String, limit: Int, completion: @escaping (Result) -> Void)
}
