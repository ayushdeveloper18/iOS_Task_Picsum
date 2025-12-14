//
//  AsyncImageLoader.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import Foundation
import SwiftUI
import UIKit


final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    private var task: URLSessionDataTask?

    func load(url: URL) {
        if let cached = ImageCache.shared[url] {
            self.image = cached
            return
        }
        isLoading = true
        let req = URLRequest(url: url, timeoutInterval: 20)
        task?.cancel()
        task = URLSession.shared.dataTask(with: req) { data, resp, err in
            defer { DispatchQueue.main.async { self.isLoading = false } }
            if let _ = err { return }
            guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode, let data = data, let ui = UIImage(data: data) else { return }
            ImageCache.shared[url] = ui
            DispatchQueue.main.async { self.image = ui }
        }
        task?.resume()
    }

    func cancel() {
        task?.cancel()
    }
}
