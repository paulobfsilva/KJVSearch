//
//  AuthenticationTokenManager.swift
//  KJVSearch
//
//  Created by Paulo Silva on 31/10/2022.
//

import Foundation

open class AuthenticationTokenManager {
    public init() {}
    open func retrieveAuthToken(completion: @escaping (String) -> Void) {
        if let authToken = UserDefaults.standard.value(forKey: Constants.userDefaultsAccessToken) as? String, let expires_in = UserDefaults.standard.value(forKey: Constants.accessTokenExpiration) as? Int, let timestamp = UserDefaults.standard.object(forKey: Constants.accessTokenGenerationTimestamp) as? Date {
            if Int(Date().timeIntervalSince(timestamp)) >= expires_in {
                generateNewAccessToken { result in
                    switch result {
                    case .success(let token):
                        completion(token)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } else {
                completion(authToken)
            }
        } else {
            generateNewAccessToken() { result in
                switch result {
                case .success(let token):
                    completion(token)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func generateNewAccessToken(completion: @escaping (Result<String, Error>)-> Void) {
        let url = URL(string: Constants.authority + "/connect/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let json = "client_id=\(Constants.clientId)&client_secret=\(Constants.clientSecret)&grant_type=client_credentials".data(using: .utf8)
        request.httpBody = json
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                print(data)
                // Handle HTTP request response
                let decoder = JSONDecoder()
                do {
                    let result = try decoder.decode(AccessTokenResponse.self, from: data)
                    let accessToken = result.access_token
                    UserDefaults.standard.set(accessToken, forKey: Constants.userDefaultsAccessToken)
                    UserDefaults.standard.set(Date(), forKey: Constants.accessTokenGenerationTimestamp)
                    UserDefaults.standard.set(result.expires_in, forKey: Constants.accessTokenExpiration)
                    completion(.success(accessToken))
                } catch let parsingError {
                    print("Error", parsingError)
                    completion(.failure(parsingError))
                }
            } else if let error = error {
                completion(.failure(error))
                print("HTTP Request Failed \(error)")
            }
        }
        task.resume()
    }
}
