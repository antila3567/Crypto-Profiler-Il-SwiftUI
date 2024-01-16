//
//  MarketDataService.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 16.01.2024.
//

import Foundation
import Combine

class MarketDataService {
    @Published var marketData: MarketData? = nil
    
    var marketDataSubscription: AnyCancellable?
    
    init(withMock: Bool) {
        if withMock {
            getMockData()
        } else {
            getData()
        }
    }
    
    public func getMockData() {
        NetworkingManager.fetchMockData(entityName: "marketDataMock") { [weak self] (result: Result<GlobalData, Error>) in
            switch result {
            case .success(let globalData):
                self?.marketData = globalData.data
            case .failure(let error):
                print("Error fetching mock data: \(error.localizedDescription)")
            }
        }
    }


    public func getData() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else { return }
        
        
        marketDataSubscription = NetworkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink { (completion) in NetworkingManager.handleCompletion(data: completion) }
            receiveValue: { [weak self] globalData in
                self?.marketData = globalData.data
                self?.marketDataSubscription?.cancel()
            }
    }
}
