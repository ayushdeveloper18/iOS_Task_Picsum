//
//  PicsumService.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import Foundation

final class PicsumService {
  
   // private let base = "https://picsum.photos/list"
    private let base = "https://picsum.photos/v2/list?page=1&limit=30"
   

    func fetchList(completion: @escaping (Result<[PicsumImage], Error>) -> Void) {
        guard let url = URL(string: base) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        NetworkService.shared.fetchDecodable(url: url, completion: completion)
    }
}
