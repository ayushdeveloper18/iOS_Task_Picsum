//
//  ImagesListViewModel.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import Foundation
import SwiftUI


final class ImagesListViewModel: ObservableObject {
    @Published private(set) var images: [PicsumImage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = PicsumService()
    private var allItems: [PicsumImage] = []
    private var pageSize = 30
    private var currentPage = 0
    private var canLoadMore: Bool { currentPage * pageSize < allItems.count }

    func loadInitial() {
        isLoading = true
        errorMessage = nil
        service.fetchList { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .failure(let e):
                    self?.errorMessage = e.localizedDescription
                case .success(let list):
                    self?.allItems = list
                    self?.currentPage = 0
                    self?.images = []
                    self?.loadNextPageIfNeeded()
                }
            }
        }
    }

    func loadNextPageIfNeeded(currentItem: PicsumImage? = nil) {
       
        if let cur = currentItem {
            guard let idx = images.firstIndex(of: cur) else { return }
            if idx < images.count - 6 { return }
        }
        
        guard !isLoading, canLoadMore else
        {
            return
        }
        isLoading = true
        // simulate background slicing
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.currentPage += 1
            let start = (self.currentPage - 1) * self.pageSize
            let end = min(start + self.pageSize, self.allItems.count)
            guard start < end else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            let slice = Array(self.allItems[start..<end])
            DispatchQueue.main.async {
                self.images.append(contentsOf: slice)
                self.isLoading = false
            }
        }
    }
    
    func setAllItemsForTesting(_ items: [PicsumImage]) {
        self.allItems = items
        self.images = []
        self.currentPage = 0
    }
}
