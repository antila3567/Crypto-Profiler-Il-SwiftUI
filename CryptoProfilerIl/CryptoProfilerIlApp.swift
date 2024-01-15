//
//  CryptoProfilerIlApp.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 15.01.2024.
//

import SwiftUI

@main
struct CryptoProfilerIlApp: App {
    @StateObject private var vm: HomeViewModel = HomeViewModel(withMock: true)
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
            .environmentObject(vm)
        }
    }
}
