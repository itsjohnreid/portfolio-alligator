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
        }
        
        func fetchRequest() {
            YahooFinanceService.publisher(request: request)
                .map { self.mapQuotes(allocations: self.allocations, response: $0) }
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
                    self.mapDifferences()
                }
                .store(in: &subscribers)
        }
        
        func mapQuotes(allocations: [Allocation], response: YahooFinanceResponse) -> [Allocation] {
            return allocations.compactMap { allocation in
                guard let result = response.quoteResponse.quotes.first(
                    where: {
                        $0.symbol.lowercased() == allocation.name.lowercased()
                    }
                )
                else { return allocation }
                return Allocation(
                    name: allocation.name,
                    targetPercentage: allocation.targetPercentage,
                    units: allocation.units,
                    price: result.regularMarketPrice,
                    difference: allocation.difference
                )
            }
        }
        
        func mapDifferences() {
            let newAllocations: [Allocation] = allocations.map { allocation in
                let otherTotal = self.total - allocation.value
                let otherPercentage = 100 - allocation.targetPercentage
                let difference = (otherTotal / otherPercentage) * allocation.targetPercentage - allocation.value
//                let difference = allocation.value - self.total * (allocation.targetPercentage/100)
                return Allocation(
                    name: allocation.name,
                    targetPercentage: allocation.targetPercentage,
                    units: allocation.units,
                    price: allocation.price,
                    difference: difference
                )
            }
            allocations = newAllocations
        }
    }
    
    class Allocation: Identifiable {
        var name: String
        var targetPercentage: Decimal
        var units: Int
        var price: Decimal?
        var difference: Decimal?
        
        public init(
            name: String,
            targetPercentage: Decimal,
            units: Int,
            price: Decimal? = nil,
            difference: Decimal? = nil
        ) {
            self.name = name
            self.targetPercentage = targetPercentage
            self.units = units
            self.price = price
            self.difference = difference
        }
        
        public var value: Decimal {
            guard let price = price else {
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
        
        public var formattedValue: String {
            guard let formattedValue = NumberFormatter.currency.string(from: value as NSNumber)
            else { return "-" }
            return formattedValue
        }
        
        public var formattedDifference: String {
            guard let difference = difference as? NSNumber,
                  let formattedDifference = NumberFormatter.currency.string(from: difference)
            else { return "" }
            return formattedDifference
        }
    }
}
