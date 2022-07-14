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
        
        var total: Decimal {
            return allocations.compactMap{ $0.value }.reduce(0, +)
        }
        
        var formattedTotal: String {
            NumberFormatter.currency.string(from: total as NSNumber) ?? "-"
        }
        
        var request: URLRequest {
            YahooFinanceService.quoteRequest(symbols: allocations.compactMap{ $0.name })
        }
        
        func addAllocation(name: String, targetPercentage: Decimal, units: Int) {
            allocations.append(
                Allocation(
                    name: name,
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
            YahooFinanceService.publisher(request: request)
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
        
        func mapQuotes(response: YahooFinanceResponse) -> [Allocation] {
            return allocations.compactMap { allocation in
                guard let quote = response.quoteResponse.quotes.first(
                    where: {
                        $0.symbol.lowercased() == allocation.name.lowercased()
                    }
                )
                else { return allocation }
                return Allocation(
                    name: allocation.name,
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
                let variation = (otherTotal / otherPercentage) * allocation.targetPercentage - allocation.value
//                let variation = allocation.value - self.total * (allocation.targetPercentage/100)
                return Allocation(
                    name: allocation.name,
                    targetPercentage: allocation.targetPercentage,
                    units: allocation.units,
                    quote: allocation.quote,
                    variation: .init(amount: variation)
                )
            }
            allocations = newAllocations
        }
    }
    
    class Allocation: Identifiable {
        var name: String
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
            name: String,
            targetPercentage: Decimal = 0,
            units: Int? = nil,
            quote: Quote? = nil,
            variation: Variation? = nil
        ) {
            self.name = name
            self.targetPercentage = targetPercentage
            self.units = units
            self.quote = quote
            self.variation = variation
        }
        
        public var value: Decimal {
            guard let price = quote?.regularMarketPrice,
                  let units = units
            else {
                return 0
            }
            return price * Decimal(units)
        }
        
        public var formattedName: String {
            name.components(separatedBy: ".")[0]
        }
        
        public var formattedTargetPercentage: String {
            (NumberFormatter.decimal.string(from: targetPercentage as NSNumber) ?? "") + "%"
        }
    }
}
