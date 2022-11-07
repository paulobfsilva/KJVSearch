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
    /// The completion handler can be invoked in any thread
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, query: String, completion: @escaping (HTTPClientResult) -> Void)
}
