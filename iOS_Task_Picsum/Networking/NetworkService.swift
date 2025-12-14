//
//  NetworkService.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case transport(Error)
    case badResponse
    case decoding(Error)
}

final class NetworkService {
  
    static let shared = NetworkService()
    
    private init() {}

    
    func fetchDecodable<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
       
        let req = URLRequest(url: url, timeoutInterval: 20)
      
        let task = URLSession.shared.dataTask(with: req) { data, resp, err in
           
            if let err = err {
                completion(.failure(NetworkError.transport(err)))
                return
            }
            guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode, let data = data else {
                completion(.failure(NetworkError.badResponse))
                return
            }
            do {
                let obj = try JSONDecoder().decode(T.self, from: data)
                completion(.success(obj))
            } catch {
                completion(.failure(NetworkError.decoding(error)))
            }
        }
        task.resume()
    }
    

    // Raw data fetcher
    func fetchData(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let req = URLRequest(url: url, timeoutInterval: 20)
        let task = URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                completion(.failure(NetworkError.transport(err)))
                return
            }
            guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode, let data = data else {
                completion(.failure(NetworkError.badResponse))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}
