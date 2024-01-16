//
//  PortfolioView.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 16.01.2024.
//

import SwiftUI

struct PortfolioView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var vm: HomeViewModel
    
    @State private var selectedCoin: Coin? = nil
    @State private var quantityText: String = ""
    @State private var showCheckmark: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SearchBarView(searchText: $vm.searchText)
                    
                    CoinLogoList
                    
                    if selectedCoin != nil {
                        PortfolioInputSection
                    }
                }
            }
            .navigationTitle("Edit Portfolio")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    XMarkBtn {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    TrailingNavBarButtons
                }
            })
            .onChange(of: vm.searchText, perform: { value in
                if value == "" {
                    resetSection()
                }
            })
        }
    }
}

extension PortfolioView {
    private func onSave() {
        guard 
            let coin = selectedCoin,
            let amount = Double(quantityText) 
            else { return }
        
        vm.updatePortfolio(coin: coin, amount: amount)
        
        withAnimation(.snappy) {
            showCheckmark = true
            resetSection()
        }
        
        UIApplication.shared.endEditing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.snappy) {
                showCheckmark = false
            }
        }
    }
    
    private func resetSection() {
        selectedCoin = nil
        vm.searchText = ""
        quantityText = ""
    }
    
    private func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        
        return 0
    }
    
    private func updateSelectedCoin(coin: Coin) {
        withAnimation(.snappy) {
            selectedCoin = coin
            
           if let portfolioCoin = vm.portfolioCoins.first(where: { $0.id == coin.id }),
              let amount = portfolioCoin.currentHoldings {
                quantityText = String(amount)
           } else {
                quantityText = ""
           }
        }
    }
    
    private var TrailingNavBarButtons: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckmark ? 1.0 : 0.0)
                .offset(x: 50)
            
            Button {
                onSave()
            } label: {
                Text("Save".uppercased())
            }
            .opacity((selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ? 1.0 : 0.0)
        }
        .font(.headline)
    }
    
    private var PortfolioInputSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Current price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                
                Spacer()
                
                Text(selectedCoin?.currentPrice.currencyWithSixDecimals() ?? "")
            }
         
            Divider()
            
            HStack {
                Text("Amount holding:")
                
                Spacer()
                
                TextField("Ex. 1.4", text: $quantityText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            
            Divider()
            
            HStack {
                Text("Current value:")
                
                Spacer()
                
                Text(getCurrentValue().currencyWithTwoDecimals())
            }
        }
        .padding(20)
        .animation(.none)
        .font(.headline)
    }
    
    private var CoinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins) { coin in
                    let isSelected = coin.id == selectedCoin?.id
                    
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                updateSelectedCoin(coin: coin)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.theme.green : Color.clear, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    PortfolioView()
        .environmentObject(HomeViewModel(withMock: true))
}
