//
//  URLSessionHTTPClient.swift
//  KJVSearch
//
//  Created by Paulo Silva on 30/10/2022.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    private let tokenManager: AuthenticationTokenManager
    
    public init(session: URLSession = .shared, tokenManager: AuthenticationTokenManager) {
        self.session = session
        self.tokenManager = tokenManager
    }
    
    private struct UnexpectedValuesRepresentationError: Error {}
    
    public func get(from url: URL, query: String, completion: @escaping (HTTPClientResult) -> Void) {
        // 1. check for auth token
        tokenManager.retrieveAuthToken { [weak self] token in
            if let request = self?.prepareRequest(url: url, query: query, token: token) {
                self?.sendRequest(request: request, completion: completion)
            }
        }
    }
    
    private func prepareRequest(url: URL, query: String, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let json: [String: Any] = [
            "data": query
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        return request
    }
    
    private func sendRequest(request: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
        session.configuration.requestCachePolicy = .returnCacheDataElseLoad
        session.dataTask(with: request, completionHandler: { data, response, error in
            if let newError = error {
                completion(.failure(newError))
            } else if let newData = data, let newResponse = response as? HTTPURLResponse {
                completion(.success(newData, newResponse))
            } else {
                completion(.failure(UnexpectedValuesRepresentationError()))
            }
        }).resume()
    }
    
}
