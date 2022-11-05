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
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(results: cache.localSearchResults, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ items: [LocalSearchItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(searchResults: items.map(CodableSearchItem.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func deleteCachedSearch(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
