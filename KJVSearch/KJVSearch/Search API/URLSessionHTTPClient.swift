//
//  URLSessionHTTPClient.swift
//  KJVSearch
//
//  Created by Paulo Silva on 30/10/2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentationError: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            if let newError = error {
                completion(.failure(newError))
            } else if let newData = data, let newResponse = response as? HTTPURLResponse {
                completion(.success(newData, newResponse))
            } else {
                completion(.failure(UnexpectedValuesRepresentationError()))
            }
        }).resume()
    }
}
