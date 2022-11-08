//
//  SearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public protocol SearchLoader {
    typealias Result = Swift.Result<[SearchItem], Error>

    func load(completion: @escaping (Result) -> Void)
}
