//
//  ContentView.swift
//  Investment Alligator
//
//  Created by John Reid on 13/3/2022.
//

import SwiftUI

struct PortfolioScene: View {
    
    @StateObject var viewModel: ViewModel
    
    @State var ticker = ""
    @State var percentage = ""
    @State var units = ""
    
    var body: some View {
        VStack(spacing: 0) {
            allocationList
            bottomBar
        }
        .navigationTitle("Portfolio Alligator")
        .toolbar {
            NavigationLink {
                SettingsScene()
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
    
    var allocationList: some View {
        List {
            Section {
                labelRow
                ForEach(viewModel.allocations) { allocation in
                    allocationRow(allocation)
                }
                .onDelete(perform: viewModel.deleteAllocation)
            } header: {
                header
            } footer: {
                HStack {
                    Spacer()
                    addAllocationButton
                    Spacer()
                }
            }
        }
        .listStyle(.grouped)
        .background(.green)
    }
    
    var header: some View {
        HStack {
            Group {
                Text("Total Portfolio:")
                    .foregroundColor(Color.secondary)
                Text(viewModel.formattedTotal)
                    .foregroundColor(Color.primary)
                    .bold()
            }
            .font(.title3)
            .textCase(nil)
        }
    }
    
    @ViewBuilder
    var bottomBar: some View {
        Divider()
        HStack {
            Group {
                TextField("Symbol", text: $ticker)
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.emailAddress)
                TextField("Target %", text: $percentage)
                    .keyboardType(.numberPad)
                TextField("Units", text: $units)
                    .keyboardType(.numberPad)
            }
            .textFieldStyle(.roundedBorder)
        }
        .padding()
        Spacer()
    }
    
    var addAllocationButton: some View {
        Button {
            viewModel.addAllocation(
                ticker: ticker,
                targetPercentage: Decimal(string: percentage) ?? 0,
                units: Int(units) ?? 0)
        } label: {
            Text("+")
                .bold()
                .font(.headline)
                .padding(.horizontal, 4)
        }
        .buttonStyle(.bordered)
    }
    
    var labelRow: some View {
        row(
            ticker: headerText("Ticker"),
            target: headerText("Target"),
            units: headerText("Units"),
            value: headerText("Value")
        )
    }
    
    func allocationRow(_ allocation: Allocation) -> some View {
        VStack {
            row(
                ticker: Text(allocation.formattedTicker)
                    .bold(),
                target: Text(allocation.formattedTargetPercentage),
                units: Text(String(allocation.units ?? 0)),
                value: Text(allocation.value.currencyString)
                )
            Spacer()
            HStack {
                Spacer()
                differenceText(allocation.variation)
            }
        }
    }
    
    func row(
        ticker: Text,
        target: Text,
        units: Text,
        value: Text
    ) -> some View {
        HStack {
            ticker
                .frame(minWidth: 60, alignment: .leading)
            target
                .frame(minWidth: 50, alignment: .leading)
            units
                .frame(minWidth: 50, alignment: .leading)
            Spacer()
            value
                .frame(minWidth: 140, alignment: .trailing)
        }
    }
    
    func headerText(_ string: String) -> Text {
        Text(string)
            .foregroundColor(Color.secondary)
            .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
    }
    
    @ViewBuilder
    func differenceText(_ variation: Allocation.Variation?) -> some View {
        switch variation {
        case .over(let amount):
            Text("\(amount.currencyString) over")
                .bold()
                .foregroundColor(Color.blue)
        case .under(let amount):
            Text("\(amount.currencyString) under")
                .bold()
                .foregroundColor(Color.orange)
        case .equal:
            Text("On target!")
                .bold()
                .foregroundColor(Color.green)
        default:
            EmptyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioScene(
            viewModel: .init(
                allocations: [
                    .init(
                        ticker: "VGS.AX",
                        targetPercentage: 50,
                        units: 50,
                        quote: .init(
                            region: nil,
                            regularMarketPrice: 129,
                            exchange: nil,
                            shortName: nil,
                            longName: nil,
                            symbol: "VGS.AX"),
                        variation: .over(amount: 938)
                    ),
                    .init(
                        ticker: "VAS.AX",
                        targetPercentage: 30,
                        units: 50,
                        quote: .init(
                            region: nil,
                            regularMarketPrice: 101,
                            exchange: nil,
                            shortName: nil,
                            longName: nil,
                            symbol: "VAS.AX"),
                        variation: .under(amount: 123)
                    ),
                    .init(
                        ticker: "VGE.AX",
                        targetPercentage: 20,
                        units: 15,
                        quote: .init(
                            region: nil,
                            regularMarketPrice: 99,
                            exchange: nil,
                            shortName: nil,
                            longName: nil,
                            symbol: "VGE.AX"),
                        variation: .under(amount: 99)
                    )
                ]
            )
        )
    }
}
