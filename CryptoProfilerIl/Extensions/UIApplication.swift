//
//  UIApplication.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 16.01.2024.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
