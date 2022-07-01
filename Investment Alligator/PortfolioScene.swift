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
        VStack {
            allocationList
            bottomBar
        }
        .navigationTitle("Investment Alligator")
    }
    
    var allocationList: some View {
        List {
            Section(header: header) {
                labelRow
                ForEach(viewModel.allocations) { allocation in
                    allocationRow(allocation)
                }
                .onDelete(perform: viewModel.deleteAllocation)
            }
        }
        .listStyle(.plain)
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
            addAllocationButton
        }
        .padding()
        Spacer()
    }
    
    var addAllocationButton: some View {
        Button {
            viewModel.addAllocation(
                name: ticker,
                targetPercentage: Decimal(string: percentage) ?? 0,
                units: Int(units) ?? 0)
        } label: {
            Text("+")
                .bold()
                .font(.title)
                .padding(.horizontal, 16)
        }
        .buttonStyle(.automatic)
    }
    
    var labelRow: some View {
        row(
            name: headerText("Name"),
            target: headerText("Target"),
            units: headerText("Units"),
            value: headerText("Value")
        )
    }
    
    func allocationRow(_ allocation: AllocationViewModel) -> some View {
        VStack {
            row(
                name: Text(allocation.formattedName)
                    .bold(),
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
    func differenceText(_ string: String) -> some View {
        if string == "" {
            EmptyView()
        } else if string.hasPrefix("-") {
            Text("\(String(string.dropFirst(1))) under")
                .bold()
                .foregroundColor(Color.orange)
        } else {
            Text("\(string) over")
                .bold()
                .foregroundColor(Color.blue)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioScene()
    }
}
