//
//  HTTPClient.swift
//  KJVSearch
//
//  Created by Paulo Silva on 28/10/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, query: String, completion: @escaping (HTTPClientResult) -> Void)
}
