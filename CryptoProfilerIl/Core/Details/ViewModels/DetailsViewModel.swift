//
//  DetailsViewModel.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 17.01.2024.
//

import Foundation
import Combine

class DetailsViewModel: ObservableObject {
    @Published var coin: Coin
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    @Published var overviewStatistic: [Statistic] = []
    @Published var additionalStatistic: [Statistic] = []
    
    private let coinDetailService: CoinDetailsDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(withMock: Bool, coin: Coin) {
        self.coinDetailService = CoinDetailsDataService(withMock: withMock, coin: coin)
        self.coin = coin
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        coinDetailService.$coinDetails
            .receive(on: DispatchQueue.main)
            .combineLatest($coin)
            .map(prepareData)
            .sink {[weak self] data in
                self?.overviewStatistic = data.overview
                self?.additionalStatistic = data.additional
            }
            .store(in: &cancellables)
        
        coinDetailService.$coinDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coinDetails in
                self?.coinDescription = coinDetails?.readableDescription
                self?.websiteURL = coinDetails?.links?.homepage?.first
                self?.redditURL = coinDetails?.links?.subredditURL
            }
            .store(in: &cancellables)
    }
    
    private func prepareData(coinDetails: CoinDetails?, coin: Coin) -> (overview: [Statistic], additional: [Statistic]) {
        return (
            prepareOverviewData(coin),
            prepareAdditionalData(coinDetails, coin)
        )
    }
    
    func prepareOverviewData(_ coin: Coin) -> [Statistic] {
        let price = coin.currentPrice.currencyWithSixDecimals()
        let pricePercentChange = coin.priceChangePercentage24H
        let priceStat = Statistic(title: "Current Price", value: price, percentageChange: pricePercentChange)
        
        let marketCap = "$" + (coin.marketCap?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange = coin.marketCapChangePercentage24H
        let marketCapStat = Statistic(title: "Market Capitalization", value: marketCap, percentageChange: marketCapPercentChange)
        
        let rank = "\(coin.rank)"
        let rankStat = Statistic(title: "Rank", value: rank)
        
        let volume = "$" + (coin.totalVolume?.formattedWithAbbreviations() ?? "")
        let volumeStat = Statistic(title: "Volume", value: volume)
        
        return [
            priceStat,
            marketCapStat,
            rankStat,
            volumeStat
        ]
    }
    
    func prepareAdditionalData(_ coinDetails: CoinDetails?, _ coin: Coin) -> [Statistic] {
        let high = coin.high24H?.currencyWithSixDecimals() ?? "n/a"
        let highStat = Statistic(title: "24h High", value: high)
        
        let low = coin.low24H?.currencyWithSixDecimals() ?? "n/a"
        let lowStat = Statistic(title: "24h Low", value: low)
        
        let priceChange = coin.priceChange24H?.currencyWithSixDecimals() ?? "n/a"
        let pricePercentChange = coin.priceChangePercentage24H
        let priceChangeStat = Statistic(title: "24h Price Change", value: priceChange, percentageChange: pricePercentChange)
        
        let marketCapChange = "$" + (coin.marketCapChange24H?.formattedWithAbbreviations() ?? "")
        let marketCapPercentChange = coin.marketCapChangePercentage24H
        let marketCapChangeStat = Statistic(title: "24h Market Cap Change", value: marketCapChange, percentageChange: marketCapPercentChange)
        
        let blockTime = coinDetails?.blockTimeInMinutes ?? 0
        let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
        let blockStat = Statistic(title: "Block Time", value: blockTimeString)
        
        let hashing = coinDetails?.hashingAlgorithm ?? "n/a"
        let hashingStat = Statistic(title: "Hashing Algoritm", value: hashing)
        
        return [
            highStat,
            lowStat,
            priceChangeStat,
            marketCapChangeStat,
            blockStat,
            hashingStat
        ]
    }
}
