//
//  NetworkingManager.swift
//  CryptoProfilerIl
//
//  Created by Иван Легенький on 15.01.2024.
//

import Foundation
import Combine

class NetworkingManager {
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badURLResponse(url: let url):
                return "[🔥] Bad response from API. URL: \(url)"
            case .unknown:
                return "[⚠] Unknown error occured."
            }
        }
    }
    
    static func download(url: URL) -> AnyPublisher<Data, Error> {
       return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap({ try handleURLResponse($0, url) })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func handleCompletion(data: Subscribers.Completion<Error>) {
        switch data {
            case .finished:
                print("Fetch is successful")
            case .failure(let error):
                print(error.localizedDescription)
        }
    }
    
    static func handleURLResponse(_ output: URLSession.DataTaskPublisher.Output, _ url: URL) throws -> Data {
        guard let httpResponse = output.response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkingError.badURLResponse(url: url)
        }
        
        return output.data
    }
    
    
    static func fetchMockData(completion: @escaping ([Coin]) -> Void) {
        guard let url = Bundle.main.url(forResource: "cryptoMock", withExtension: "json") else {
            print("Failed to find JSON file")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let jsonData = data else {
                print("No data found")
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode([Coin].self, from: jsonData)
                completion(decodedData)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
}
