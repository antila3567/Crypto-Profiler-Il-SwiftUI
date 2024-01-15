//
//  CoinDataService.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 15.01.2024.
//

import Foundation
import Combine

class CoinDataService {
    @Published var allCoins: [Coin] = []
    
    var coindSubscription: AnyCancellable?
    
    init(withMock: Bool) {
        if withMock {
            getMockCoins()
        } else {
            getCoins()
        }
    }
    
    private func getMockCoins() {
        NetworkingManager.fetchMockData { [weak self] coins in
            self?.allCoins = coins
        }
    }
    
    private func getCoins() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h&locale=en")
        else { return }
        
        
        coindSubscription = NetworkingManager.download(url: url)
            .decode(type: [Coin].self, decoder: JSONDecoder())
            .sink { (completion) in NetworkingManager.handleCompletion(data: completion) }
            receiveValue: { [weak self] coins in
                self?.allCoins = coins
                self?.coindSubscription?.cancel()
            }
    }
}
