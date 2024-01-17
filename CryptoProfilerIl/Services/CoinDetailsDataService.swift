//
//  CoinDetailsDataService.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 17.01.2024.
//

import Foundation
import Combine


class CoinDetailsDataService {
    @Published var coinDetails: CoinDetails? = nil
    
    var coindDetailsSubscription: AnyCancellable?
    
    let coin: Coin
    
    init(withMock: Bool, coin: Coin) {
        self.coin = coin
        
        if withMock {
            getMockData()
        } else {
            getData()
        }
    }
    
    public func getMockData() {
        NetworkingManager.fetchMockData(entityName: "coinDetailsMock") { [weak self] (result: Result<CoinDetails, Error>) in
            switch result {
            case .success(let data):
                self?.coinDetails = data
            case .failure(let error):
                print("Error fetching mock data: \(error.localizedDescription)")
            }
        }
    }
    
    
    public func getData() {
        print("Loading real data")
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
        else { return }
        
        
        coindDetailsSubscription = NetworkingManager.download(url: url)
            .decode(type: CoinDetails.self, decoder: JSONDecoder())
            .sink { (completion) in NetworkingManager.handleCompletion(data: completion) }
            receiveValue: { [weak self] data in
                self?.coinDetails = data
                self?.coindDetailsSubscription?.cancel()
            }
    }
}
