//
//  HomeViewModel.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 15.01.2024.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var statistic: [Statistic] = []
    @Published var allCoins: [Coin] = []
    @Published var portfolioCoins: [Coin] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var sortOption: SortOption = .holdings
    
    private let coinDataService: CoinDataService
    private let marketDataService: MarketDataService
    private let portfolioDataService = PortfolioDataService()
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption {
        case rank, rankReversed, holdings, holdingReversed, price, priceReversed
    }
    
    init(withMock: Bool) {
        self.coinDataService = CoinDataService(withMock: withMock)
        self.marketDataService = MarketDataService(withMock: withMock)
        
        addSubscribers()
    }
    
    func addSubscribers() {
        $searchText
            .receive(on: DispatchQueue.main)
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(prepareCoinsWithCriteria)
            .sink { [weak self] coins in
                self?.allCoins = coins
            }
            .store(in: &cancellables)
        
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(updateHoldings)
            .sink { [weak self] coins in
                guard let self = self else { return }
                
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: coins)
            }
            .store(in: &cancellables)
        
        marketDataService.$marketData
            .receive(on: DispatchQueue.main)
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] stats in
                self?.statistic = stats
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: Coin, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func reloadData(withMock: Bool) {
        isLoading = true
        if withMock {
            coinDataService.getMockCoins()
            marketDataService.getMockData()
        } else {
            coinDataService.getCoins()
            marketDataService.getData()
        }
        HapticManager.notification(type: .success)
    }
    
    private func updateHoldings(coinModels: [Coin], portfolioEntities: [Portfolio]) -> [Coin] {
        coinModels
            .compactMap { coin in
                guard let entity = portfolioEntities.first(where: {$0.coinID == coin.id}) else {
                    return nil
                }
                
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    private func mapGlobalMarketData(data: MarketData?, portfolioCoins: [Coin]) -> [Statistic] {
        var stats: [Statistic] = []
        
        guard let data = data else { return stats }
        
        let marketCap = Statistic(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = Statistic(title: "24h Volume", value: data.volume)
        let btcDominance = Statistic(title: "BTC Dominance", value: data.btcDominance)
        
  
        let portfolioValue = portfolioCoins.map({ $0.currentHoldingsValue }).reduce(0, +)
        
        let previousValue = portfolioCoins.map { (coin) -> Double in
            let currentValue = coin.currentHoldingsValue
            let percentChange = (coin.priceChangePercentage24H ?? 0) / 100
            let prevValue = currentValue / (1 + percentChange)
            return prevValue
        }.reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        let portfolio = Statistic(
            title: "Portfolio Value",
            value: portfolioValue.currencyWithTwoDecimals(),
            percentageChange: percentageChange
        )
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        
        return stats
    }
    
    private func prepareCoinsWithCriteria(_ text: String, _ coins: [Coin], sort: SortOption) -> [Coin] {
        var preparedCoins = filterCoins(text, coins)
        
        sortCoins(sort: sort, coins: &preparedCoins)
        
        return preparedCoins
    }
    
    private func sortCoins(sort: SortOption, coins: inout [Coin]) {
        switch sort {
        case .rank, .holdings:
            coins.sort(by: { $0.rank < $1.rank})
        case .rankReversed, .holdingReversed:
            coins.sort(by: { $0.rank > $1.rank})
        case .price:
            coins.sort(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            coins.sort(by: { $0.currentPrice < $1.currentPrice })
        }
    }
    
    private func sortPortfolioCoinsIfNeeded(coins: [Coin]) -> [Coin] {
        switch sortOption {
        case .holdings:
            return coins.sorted(by: { $0.currentHoldingsValue < $1.currentHoldingsValue})
        case .holdingReversed:
            return coins.sorted(by: { $0.currentHoldingsValue > $1.currentHoldingsValue})
        default:
            return coins
        }
    }
    
    private func filterCoins(_ text: String, _ coins: [Coin]) -> [Coin] {
        guard !text.isEmpty else { return coins }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { coin in
            return coin.name.lowercased().contains(lowercasedText) ||
                   coin.symbol.lowercased().contains(lowercasedText) ||
                   coin.id.lowercased().contains(lowercasedText)
        }
    }
}
