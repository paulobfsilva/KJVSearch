//
//  SearchItem.swift
//  KJVSearch
//
//  Created by Paulo Silva on 26/10/2022.
//

import Foundation

public struct SearchItem: Equatable, Decodable {
    public let sampleId: String
    public let distance: Double
    public let externalId: String
    public let data: String
    
    public init(sampleId: String, distance: Double, externalId: String, data: String) {
        self.sampleId = sampleId
        self.distance = distance
        self.externalId = externalId
        self.data = data
    }
}
