//
//  QuoteResponse.swift
//  Investment Alligator
//
//  Created by John Reid on 21/3/2022.
//

import Foundation

struct YahooFinanceResponse: Decodable {
    
    let quoteResponse: QuoteResponse
    
    struct QuoteResponse: Decodable {
        
        let result: [Result]
        
        struct Result: Decodable {
            let region: String
            let regularMarketPrice: Decimal
            let exchange: String
            let shortName: String
            let longName: String
            let symbol: String
        }
    }
}
