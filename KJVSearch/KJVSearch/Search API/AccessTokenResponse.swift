//
//  AccessTokenResponse.swift
//  KJVSearch
//
//  Created by Paulo Silva on 31/10/2022.
//

import Foundation

struct AccessTokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let expires_in: Int
}
