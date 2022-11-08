//
//  RemoteSearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public final class RemoteSearchLoader: SearchLoader {
    
    private let url: URL
    private let client: HTTPClient
    private let query: String
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = SearchLoader.Result
    
    public init(url: URL, client: HTTPClient, query: String) {
        self.url = url
        self.client = client
        self.query = query
    }
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, query: query) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteSearchLoader.decode(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func decode(_ data: Data, from response: HTTPURLResponse) -> Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.searchSamples.toModels())
        } else {
            return .failure(Error.invalidData)
        }
    }
}

private struct Root: Decodable {
    let searchSamples: [RemoteSearchItem]
}

private extension Array where Element == RemoteSearchItem {
    func toModels() -> [SearchItem] {
        return map { SearchItem(sampleId: $0.sampleId, distance: $0.distance, externalId: $0.externalId, data: $0.data)}
    }
}
