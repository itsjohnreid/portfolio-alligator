//
//  ContentView.swift
//  Investment Alligator
//
//  Created by John Reid on 13/3/2022.
//

import SwiftUI

struct PortfolioScene: View {
    
    @StateObject var viewModel = ViewModel()
    
    @State var ticker = ""
    @State var percentage = ""
    @State var units = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    headerRow
                    ForEach(viewModel.allocations) { allocation in
                        allocationRow(allocation)
                    }
                    HStack {
                        Spacer()
                        Button("+") {
                            viewModel.addAllocation(
                                name: ticker,
                                targetPercentage: Decimal(string: percentage) ?? 0,
                                units: Int(units) ?? 0)
                        }
                        .buttonStyle(.automatic)
                        Spacer()
                    }
                }
                TextField("Ticker", text: $ticker)
                TextField("Percentage", text: $percentage)
                TextField("Units", text: $units)
                Text(String(format: Strings.footer, viewModel.formattedTotal))
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .navigationTitle(Text(Strings.title))
        }
    }
    
    @ViewBuilder
    func allocationRow(_ allocation: AllocationViewModel) -> some View {
        VStack {
            row(
                name: Text(allocation.formattedName)
                    .fontWeight(.bold),
                target: Text(allocation.formattedTargetPercentage),
                units: Text(String(allocation.units)),
                value: Text(allocation.formattedValue)
                )
            Spacer()
            HStack {
                Spacer()
                differenceText(allocation.formattedDifference)
            }
        }
    }
    
    var headerRow: some View {
        row(
            name: headerText("Name"),
            target: headerText("Target"),
            units: headerText("Units"),
            value: headerText("Value")
        )
    }
    
    @ViewBuilder
    func row(
        name: Text,
        target: Text,
        units: Text,
        value: Text
    ) -> some View {
        HStack {
            name
                .frame(minWidth: 60, alignment: .leading)
            target
                .frame(minWidth: 50, alignment: .leading)
            Spacer()
            units
                .frame(minWidth: 60, alignment: .leading)
            value
                .frame(minWidth: 100, alignment: .trailing)
        }
    }
    
    @ViewBuilder
    func headerText(_ string: String) -> Text {
        Text(string)
            .foregroundColor(Color.secondary)
            .font(/*@START_MENU_TOKEN@*/.subheadline/*@END_MENU_TOKEN@*/)
    }
    
    @ViewBuilder
    func differenceText(_ string: String) -> some View {
        if string.hasPrefix("-") {
            Text("\(string) under")
                .fontWeight(.bold)
                .foregroundColor(Color.orange)
        } else {
            Text("\(string) over")
                .fontWeight(.bold)
                .foregroundColor(Color.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioScene()
    }
}
