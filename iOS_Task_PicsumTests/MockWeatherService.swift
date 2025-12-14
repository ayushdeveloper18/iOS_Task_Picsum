//
//  MockWeatherService.swift
//  iOS_Task_PicsumTests
//
//  Created by Ayush Sharma on 15/12/25.
//


import Foundation
@testable import iOS_Task_Picsum

final class MockWeatherService: WeatherServiceProtocol {

    var result: Result<WeatherModel, Error>?

    func fetchCurrentWeather(
        lat: Double,
        lon: Double,
        completion: @escaping (Result<WeatherModel, Error>) -> Void
    ) {
        // Simulate async behavior
        DispatchQueue.main.async {
            if let result = self.result {
                completion(result)
            }
        }
    }
}
