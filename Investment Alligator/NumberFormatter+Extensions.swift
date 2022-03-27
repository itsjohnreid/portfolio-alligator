//
//  NumberFormatter+Extensions.swift
//  Investment Alligator
//
//  Created by John Reid on 18/3/2022.
//

import Foundation

extension NumberFormatter {
    public static var decimal: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    public static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter
    }
}
