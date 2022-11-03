//
//  SearchItemsMapper.swift
//  KJVSearch
//
//  Created by Paulo Silva on 03/11/2022.
//

import Foundation

internal struct RemoteSearchItem: Decodable {
    internal let sampleId: String
    internal let distance: Double
    internal let externalId: String
    internal let data: String
}
