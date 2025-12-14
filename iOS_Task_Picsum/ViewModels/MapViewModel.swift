//
//  MapViewModel.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//

import Foundation

final class MapViewModel: ObservableObject {
    @Published var images: [PicsumImage] = []
    @Published var selectedImage: PicsumImage?
    @Published var weather: WeatherModel?
    @Published var isLoadingWeather = false
    @Published var errorMessage: String?

    private let weatherService = WeatherService()
    
    private let weatherServices: WeatherServiceProtocol?
    
    // for testCases 
    init(weatherServices: WeatherServiceProtocol = WeatherService()) {
            
        self.weatherServices = weatherServices
       
    }

    func load(images: [PicsumImage]) {
        self.images = images
    }

    func select(image: PicsumImage) {
        self.selectedImage = image
        fetchWeather(for: image)
    }

   
    private func fetchWeather(for image: PicsumImage) {
        isLoadingWeather = true
        errorMessage = nil
        weather = nil

        let coord = image.coordinate

        weatherService.fetchCurrentWeather(lat: coord.lat, lon: coord.lon) { result in
            switch result {
            case .success(let weather):

                if Thread.isMainThread {
                    self.weather = weather
                    self.isLoadingWeather = false
                } else {
                    DispatchQueue.main.async {
                        self.weather = weather
                        self.isLoadingWeather = false
                    }
                }

            case .failure(let error):

                if Thread.isMainThread {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingWeather = false
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.isLoadingWeather = false
                    }
                }
            }
        }
    }

}
