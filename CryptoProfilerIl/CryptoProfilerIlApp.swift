//
//  CryptoProfilerIlApp.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 15.01.2024.
//

import SwiftUI

@main
struct CryptoProfilerIlApp: App {
    @StateObject private var vm: HomeViewModel = HomeViewModel(withMock: false)
    @State private var showLaunchView: Bool = true
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationView {
                    HomeView()
                        .navigationBarHidden(true)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .environmentObject(vm)
                
                ZStack {
                    if showLaunchView {
                        LaunchView(showLaunchView: $showLaunchView)
                            .transition(.move(edge: .top))
                    }
                }
                .zIndex(2.0)
            }
        }
    }
}
