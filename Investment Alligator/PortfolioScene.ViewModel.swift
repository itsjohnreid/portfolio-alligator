//
//  PortfolioViewModel.swift
//  Investment Alligator
//
//  Created by John Reid on 13/3/2022.
//

import Foundation
import Combine

extension PortfolioScene {
    
    class ViewModel: ObservableObject {
        
        private var subscribers: Set<AnyCancellable> = []
        
        @Published var allocations: [Allocation] = []
        
        public init(allocations: [Allocation] = []) {
            self.allocations = allocations
        }
        
        var total: Decimal {
            return allocations.compactMap{ $0.value }.reduce(0, +)
        }
        
        var formattedTotal: String {
            NumberFormatter.currency.string(from: total as NSNumber) ?? "-"
        }
        
        var request: URLRequest {
            YHFinanceService.quoteRequest(symbols: allocations.compactMap{ $0.ticker })
        }
        
        func addAllocation(ticker: String, targetPercentage: Decimal, units: Int) {
            allocations.append(
                Allocation(
                    ticker: ticker,
                    targetPercentage: targetPercentage,
                    units: units
                )
            )
            fetchRequest()
        }
        
        func deleteAllocation(at offsets: IndexSet) {
            allocations.remove(atOffsets: offsets)
            mapVariations()
        }
        
        func fetchRequest() {
            YHFinanceService.publisher(request: request)
                .map { self.mapQuotes(response: $0) }
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        debugPrint("finished")
                    case .failure(let error):
                        debugPrint("error = \(error.localizedDescription)")
                    }
                } receiveValue: {
                    self.allocations = $0
                    self.mapVariations()
                }
                .store(in: &subscribers)
        }
        
        func mapQuotes(response: YHFinanceResponse) -> [Allocation] {
            return allocations.compactMap { allocation in
                guard let quote = response.quoteResponse.quotes?.first(
                    where: {
                        $0.symbol?.lowercased() == allocation.ticker.lowercased()
                    }
                )
                else { return allocation }
                return Allocation(
                    ticker: allocation.ticker,
                    targetPercentage: allocation.targetPercentage,
                    units: allocation.units,
                    quote: quote,
                    variation: allocation.variation
                )
            }
        }
        
        func mapVariations() {
            let newAllocations: [Allocation] = allocations.map { allocation in
                let otherTotal = self.total - allocation.value
                let otherPercentage = 100 - allocation.targetPercentage
                let targetValue = otherPercentage == 0
                    ? allocation.value
                    : (otherTotal / otherPercentage) * allocation.targetPercentage
                let variation = allocation.value - targetValue
                return Allocation(
                    ticker: allocation.ticker,
                    targetPercentage: allocation.targetPercentage,
                    units: allocation.units,
                    quote: allocation.quote,
                    variation: .init(amount: variation)
                )
            }
            allocations = newAllocations
        }
    }
    
    struct Allocation: Identifiable {
        
        var ticker: String
        var targetPercentage: Decimal
        var units: Int?
        var quote: Quote?
        var variation: Variation?
        
        enum Variation {
            case over(amount: Decimal)
            case under(amount: Decimal)
            case equal
            case none
            
            init (amount: Decimal) {
                if amount > 0 {
                    self = .over(amount: amount)
                } else if amount < 0 {
                    self = .under(amount: abs(amount))
                } else {
                    self = .equal
                }
            }
        }
        
        public init(
            ticker: String,
            targetPercentage: Decimal = 0,
            units: Int? = nil,
            quote: Quote? = nil,
            variation: Variation? = nil
        ) {
            self.ticker = ticker
            self.targetPercentage = targetPercentage
            self.units = units
            self.quote = quote
            self.variation = variation
        }
        
        var id: String {
            ticker
        }
        
        var value: Decimal {
            guard let price = quote?.regularMarketPrice,
                  let units = units
            else {
                return 0
            }
            return price * Decimal(units)
        }
        
        var formattedTicker: String {
            ticker.components(separatedBy: ".")[0]
        }
        
        var formattedTargetPercentage: String {
            (NumberFormatter.decimal.string(from: targetPercentage as NSNumber) ?? "") + "%"
        }
    }
}
