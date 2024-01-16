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
        NetworkingManager.fetchMockData(entityName: "cryptoMock") { [weak self] (result: Result<[Coin], Error>) in
            switch result {
            case .success(let data):
                self?.allCoins = data
            case .failure(let error):
                print("Error fetching mock data: \(error.localizedDescription)")
            }
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
