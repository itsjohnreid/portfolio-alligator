//
//  Investment_AlligatorApp.swift
//  Investment Alligator
//
//  Created by John Reid on 13/3/2022.
//

import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                PortfolioScene(viewModel: .init())
            }
        }
    }
}
