//
//  StatisticModel.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 16.01.2024.
//

import Foundation

struct Statistic: Identifiable {
    let id: UUID = .init()
    let title: String
    let value: String
    let percentageChange: Double?
    
    init(title: String, value: String, percentageChange: Double? = nil) {
        self.title = title
        self.value = value
        self.percentageChange = percentageChange
    }
}
