//
//  SearchCacheTestHelpers.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 03/11/2022.
//

import Foundation
import KJVSearch

internal func uniqueItem() -> SearchItem {
    // sampleId is what makes a SearchItem unique
    return SearchItem(sampleId: UUID().uuidString, distance: 0.5, externalId: "externalId", data: "data")
}

internal func uniqueItems() -> (models: [SearchItem], local: [LocalSearchItem]) {
    let models = [uniqueItem(), uniqueItem()]
    let local = models.map { LocalSearchItem(sampleId: $0.sampleId, distance: $0.distance, externalId: $0.externalId, data: $0.data) }
    return (models, local)
}

internal func anyQuery() -> String {
    return "any query string"
}

internal extension Date {
    func minusSearchCacheMaxAge() -> Date {
        return adding(days: -searchCacheMaxAgeInDays)
    }
    
    private var searchCacheMaxAgeInDays: Int {
        return 30
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

internal extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
