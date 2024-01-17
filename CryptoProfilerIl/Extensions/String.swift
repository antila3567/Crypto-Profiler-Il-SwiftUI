//
//  String.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 17.01.2024.
//

import Foundation

extension String {
    var removingHTMLOccurances: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
