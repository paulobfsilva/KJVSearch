//
//  CodableSearchStore.swift
//  KJVSearch
//
//  Created by Paulo Silva on 05/11/2022.
//

import Foundation

public class CodableSearchStore: SearchStore {

    private struct Cache: Codable {
        let searchResults: [CodableSearchItem]
        let timestamp: Date
        
        var localSearchResults: [LocalSearchItem] {
            return searchResults.map { $0.local }
        }
    }
    
    private struct CodableSearchItem: Codable {
        private let sampleId: String
        private let distance: Double
        private let externalId: String
        private let data: String
        
        init(_ searchResults: LocalSearchItem) {
            sampleId = searchResults.sampleId
            distance = searchResults.distance
            externalId = searchResults.externalId
            data = searchResults.data
        }
        
        var local: LocalSearchItem {
            return LocalSearchItem(sampleId: sampleId, distance: distance, externalId: externalId, data: data)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableSearchStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(.some(CachedSearchResults(results: cache.localSearchResults, timestamp: cache.timestamp))))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ items: [LocalSearchItem], timestamp: Date, query: String, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(searchResults: items.map(CodableSearchItem.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(.success(Void()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedSearch(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(.success(Void()))
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(Void()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
