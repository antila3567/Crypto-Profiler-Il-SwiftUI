//
//  SettingsView.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 17.01.2024.
//

import SwiftUI

struct SettingsView: View {
    let defURL = URL(string: "https://www.google.com")!
    let coingeckoURL = URL(string: "https://www.coingecko.com")!
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            List {
                AppInfo
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    XMarkBtn {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
    }
}

extension SettingsView {
    private var AppInfo: some View {
        Section(header: Text("Crypto app")) {
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("The app is for tracking and profiling crypto currencies. It is based on coingecko API.")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.vertical)
            Link("Test Google URL", destination: defURL)
                .accentColor(.blue)
            Link("Coingecko API", destination: coingeckoURL)
                .accentColor(.blue)
        }
    }
}

#Preview {
    SettingsView()
}
