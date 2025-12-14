//
//  ImagesListViewModelTests.swift
//  iOS_Task_PicsumTests
//
//  Created by Ayush Sharma on 15/12/25.
//

import XCTest
@testable import iOS_Task_Picsum

final class ImagesListViewModelTests: XCTestCase {

    func testPaginationLoadsNextPage() {
      
        let vm = ImagesListViewModel()
          
         let fakeImages = (1...50).map {
            PicsumImage(
                id: "\($0)",
                author: "Author \($0)",
                width: 100,
                height: 100,
                url: nil,
                download_url: nil
            )
        }

        vm.setAllItemsForTesting(fakeImages)

        XCTAssertEqual(vm.images.count, 0)

        let expectation = expectation(description: "Pagination loaded")

        // Load first page
        vm.loadNextPageIfNeeded()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(vm.images.count, 30)

            // Load second page
            vm.loadNextPageIfNeeded()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                XCTAssertEqual(vm.images.count, 50)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
