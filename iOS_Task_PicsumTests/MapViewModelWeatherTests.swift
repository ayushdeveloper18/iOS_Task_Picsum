//
//  MapViewModelWeatherTests.swift
//  iOS_Task_PicsumTests
//
//  Created by Ayush Sharma on 15/12/25.
//

import XCTest
@testable import iOS_Task_Picsum

final class MapViewModelWeatherTests: XCTestCase {
    
    func testWeatherFetchSuccess() {
        let mockService = MockWeatherService()
        mockService.result = .success(
            WeatherModel(
                
                provider: "open-meteo",
                
                temperatureC: 25.0,
                humidityPct: 60,
                windSpeed: 5.5,
                rawJSON: nil
            )
        )
        
        let vm = MapViewModel(weatherServices: mockService)
        
        let image = PicsumImage(
            id: "1",
            author: "Test",
            width: nil,
            height: nil,
            url: nil,
            download_url: nil
        )
        
        vm.select(image: image)
        
        XCTAssertEqual(vm.weather?.temperatureC, 25.0)
        XCTAssertEqual(vm.weather?.humidityPct, 60)
        XCTAssertEqual(vm.weather?.windSpeed, 5.5)
        XCTAssertFalse(vm.isLoadingWeather)
    }
}
