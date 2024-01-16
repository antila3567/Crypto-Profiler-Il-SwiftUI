//
//  XMarkBtn.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 16.01.2024.
//

import SwiftUI

struct XMarkBtn: View {
    var callback: () -> Void
    
    var body: some View {
        Button {
            callback()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
        }
    }
}

