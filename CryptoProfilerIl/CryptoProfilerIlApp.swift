//
//  CryptoProfilerIlApp.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 15.01.2024.
//

import SwiftUI

@main
struct CryptoProfilerIlApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
        }
    }
}
