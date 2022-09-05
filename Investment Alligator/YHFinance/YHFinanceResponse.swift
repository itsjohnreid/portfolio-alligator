//
//  YHFinanceResponse.swift
//  Investment Alligator
//
//  Created by John Reid on 21/3/2022.
//

import Foundation

typealias Quote = YHFinanceResponse.QuoteResponse.Quote

struct YHFinanceResponse: Decodable {
    
    let quoteResponse: QuoteResponse
    
    struct QuoteResponse: Decodable {
        
        let quotes: [Quote]?
        
        struct Quote: Decodable {
            let region: String?
            let regularMarketPrice: Decimal?
            let exchange: String?
            let shortName: String?
            let longName: String?
            let symbol: String?
        }
        
        private enum CodingKeys: String, CodingKey {
            case quotes = "result"
        }
    }
}
