//
//  SharedTestHelpers.swift
//  KJVSearchTests
//
//  Created by Paulo Silva on 03/11/2022.
//

import Foundation

func anyError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
