//
//  DetailsView.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 17.01.2024.
//

import SwiftUI

struct DetailsLoadingView: View {
    @Binding var coin: Coin?
    
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailsView(coin: coin)
            }
        }
    }
}

struct DetailsView: View {
    @StateObject private var vm: DetailsViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    private let spacing: CGFloat = 30
    
    init(coin: Coin) {
        _vm = StateObject(wrappedValue: DetailsViewModel(withMock: true, coin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ChartView(coin: vm.coin)
                    .padding(.top)
                
                VStack(spacing: 20) {
                    
                    OverviewTitle
                
                    Divider()
                    
                    OverviewGrid
                    
                    AdditionalTitle
                    
                    Divider()
                    
                    AdditionalGrid
                }
                .padding()
            }
        }
        .navigationTitle(vm.coin.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing, content: {
                NavigationBarCoinInfo
            })
        }
    }
}

extension DetailsView {
    private var NavigationBarCoinInfo: some View {
        HStack {
            Text(vm.coin.symbol.uppercased())
                .font(.headline)
                .foregroundColor(Color.theme.secondaryText)
            
            CoinImageView(coin: vm.coin)
                .frame(width: 25, height: 25)
        }
    }
    
    private var OverviewTitle: some View {
        Text("Overview")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var AdditionalTitle: some View {
        Text("Additional Details")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var OverviewGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: [],
            content: {
                ForEach(vm.overviewStatistic) { stat in
                    StatisticView(statistic: Statistic(title: stat.title, value: stat.value, percentageChange: stat.percentageChange))
                }
        })
    }
    
    private var AdditionalGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: [],
            content: {
                ForEach(vm.additionalStatistic) { stat in
                    StatisticView(statistic: Statistic(title: stat.title, value: stat.value, percentageChange: stat.percentageChange))
                }
        })
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsView(coin: dev.coin)
        }
    }
}
