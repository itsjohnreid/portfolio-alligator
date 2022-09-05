//
//  Settings.swift
//  Investment Alligator
//
//  Created by John Reid on 6/9/2022.
//

import Foundation

struct Settings {
    private static let userDefaults = UserDefaults.standard
    
    static var yhFinanceApiKey: String? {
        get {
            userDefaults.string(forKey: SettingKey.yhFinanceApiKey.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: SettingKey.yhFinanceApiKey.rawValue)
        }
    }
    
    enum SettingKey: String {
        case yhFinanceApiKey
    }
}
