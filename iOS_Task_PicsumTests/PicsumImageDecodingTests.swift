//
//  PicsumImageDecodingTests.swift
//  iOS_Task_PicsumTests
//
//  Created by Ayush Sharma on 15/12/25.
//



import XCTest
@testable import iOS_Task_Picsum


final class PicsumImageDecodingTests: XCTestCase {

    func testPicsumImageDecoding() throws {
        let json = """
        [
          {
            "id": "10",
            "author": "Paul Jarvis",
            "width": 2500,
            "height": 1667,
            "url": "https://unsplash.com/photos/6J--NXulQCs",
            "download_url": "https://picsum.photos/id/10/2500/1667"
          }
        ]
        """.data(using: .utf8)!

        let images = try JSONDecoder().decode([PicsumImage].self, from: json)

        XCTAssertEqual(images.count, 1)
        XCTAssertEqual(images.first?.id, "10")
        XCTAssertEqual(images.first?.author, "Paul Jarvis")
        XCTAssertEqual(images.first?.width, 2500)
        XCTAssertEqual(images.first?.height, 1667)
    }
}
