//
//  YahooFinanceRepository.swift
//  Investment Alligator
//
//  Created by John Reid on 21/3/2022.
//

import Foundation
import Combine

enum YahooFinanceService {
    
    static func quoteRequest(symbols: [String]) -> URLRequest {
        let symbolString = symbols.joined(separator: ",")
        return request(
            endURLPath: "quote",
            queryItems: [
                URLQueryItem(name: "symbols", value: symbolString)
            ]
        )
    }
    
    static func request(
        endURLPath: String,
        queryItems: [URLQueryItem]
    ) -> URLRequest {
        let apiKey = "TQhWr8g1df8TSAa8EUHVC2CmyJA0ueKh8gRLDFEn"
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "yfapi.net"
        urlComponents.path = "/v6/finance"
        urlComponents.queryItems = queryItems
        
        var urlRequest = URLRequest(url: urlComponents.url!.appendingPathComponent(endURLPath))
        urlRequest.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        return urlRequest
    }
    
    static func publisher<Output: Decodable>(request: URLRequest) -> AnyPublisher<Output, Swift.Error> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data: Data, response: URLResponse) in
                return data
            }
            .decode(type: Output.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
