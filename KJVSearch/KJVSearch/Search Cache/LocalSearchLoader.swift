//
//  LocalSearchLoader.swift
//  KJVSearch
//
//  Created by Paulo Silva on 02/11/2022.
//

import Foundation

public final class LocalSearchLoader {
    private let store: SearchStore
    private let currentDate: () -> Date
    
    public init(store: SearchStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalSearchLoader {
    public typealias SaveResult = Error?

    public func save(_ items: [SearchItem], query: String, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedSearch { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, query: query, with: completion)
            }
        }
    }
    
    private func cache(_ items: [SearchItem], query: String, with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: currentDate(), query: query) { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        }
    }
}

extension LocalSearchLoader: SearchLoader {
    public typealias LoadResult = SearchLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.found(results, timestamp)) where SearchCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(results.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

extension LocalSearchLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedSearch { _ in }
            case let .success(.found(_, timestamp)) where !SearchCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedSearch { _ in }
            case .success: break
            }
        }
        
    }
}

private extension Array where Element == SearchItem {
    func toLocal() -> [LocalSearchItem] {
        return map { LocalSearchItem(sampleId: $0.sampleId, distance: $0.distance, externalId: $0.externalId, data: $0.data)}
    }
}

private extension Array where Element == LocalSearchItem {
    func toModels() -> [SearchItem] {
        return map { SearchItem(sampleId: $0.sampleId, distance: $0.distance, externalId: $0.externalId, data: $0.data)}
    }
}

