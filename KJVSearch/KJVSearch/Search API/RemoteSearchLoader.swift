//
//  RemoteSearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public final class RemoteSearchLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        // TODO: - represent error where access token is expired
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([SearchItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteSearchLoader.decode(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private static func decode(_ data: Data, from response: HTTPURLResponse) -> Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.searchSamples)
        } else {
            return .failure(.invalidData)
        }
    }
}

private struct Root: Decodable {
    let searchSamples: [SearchItem]
}
