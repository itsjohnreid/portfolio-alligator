//
//  SettingsScene.swift
//  Investment Alligator
//
//  Created by John Reid on 6/9/2022.
//

import SwiftUI

struct SettingsScene: View {
    @State var yhFinanceApiKey: String = ""
    
    var body: some View {
        List {
            Section(
                header: Text("API key"),
                footer: apiKeyFooter
            ) {
                TextField(
                    "Enter your API access key", text: $yhFinanceApiKey
                )
                .submitLabel(.done)
                .onSubmit {
                    Settings.yhFinanceApiKey = yhFinanceApiKey
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            yhFinanceApiKey = Settings.yhFinanceApiKey ?? ""
        }
    }
    
    var apiKeyFooter: Text {
        Text("We use the **YH Finance API** for stock info. You can get a free API key here: ") +
        Text("[https://financeapi.net](https://financeapi.net/pricing)")
    }
}

struct SettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScene()
    }
}
