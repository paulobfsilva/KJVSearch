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
    let calendar = Calendar(identifier: .gregorian)
    
    public init(store: SearchStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 30
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}

extension LocalSearchLoader {
    public typealias SaveResult = Error?

    public func save(_ items: [SearchItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedSearch { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [SearchItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] cacheInsertionError in
            guard self != nil else { return }
            completion(cacheInsertionError)
        }
    }
}

extension LocalSearchLoader: SearchLoader {
    public typealias LoadResult = LoadSearchResult

    public func load(completion: @escaping (LoadSearchResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(results, timestamp) where self.validate(timestamp):
                completion(.success(results.toModels()))
            case .found, .empty:
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
            case let .found(_, timestamp) where !self.validate(timestamp):
                self.store.deleteCachedSearch { _ in }
            case .empty, .found: break
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

