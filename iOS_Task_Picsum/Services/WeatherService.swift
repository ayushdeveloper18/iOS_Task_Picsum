//
//  WeatherService.swift
//  iOS_Task_Picsum
//
//  Created by Ayush Sharma on 12/12/25.
//
import Foundation

protocol WeatherServiceProtocol {
    func fetchCurrentWeather(
        lat: Double,
        lon: Double,
        completion: @escaping (Result<WeatherModel, Error>) -> Void
    )
}



final class WeatherService {
    // Builds the exact URL the PDF doc used:
    // https://api.open-meteo.com/v1/forecast?latitude=<lat>&longitude=<lon>&current=temperature_2m,relative_humidity_2m,wind_speed_10m
  
    
    func fetchCurrentWeather(lat: Double, lon: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        var comps = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        comps?.queryItems = [
            URLQueryItem(name: "latitude", value: "\(lat)"),
            URLQueryItem(name: "longitude", value: "\(lon)"),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,wind_speed_10m"),
            URLQueryItem(name: "timezone", value: "UTC")
        ]
        guard let url = comps?.url else {
            completion(.failure(NetworkError.badURL))
            return
        }

        NetworkService.shared.fetchData(url: url) { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success(let data):
                // Parse flexibly
                do {
                    let jsonAny = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let dict = jsonAny as? [String: Any] else {
                        completion(.success(WeatherModel(provider: "open-meteo", temperatureC: nil, humidityPct: nil, windSpeed: nil, rawJSON: nil)))
                        return
                    }
                    let parsed = WeatherService.parseOpenMeteo(dict: dict)
                    completion(.success(parsed))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    private static func parseOpenMeteo(dict: [String: Any]) -> WeatherModel {
        // Look for current_weather
        var temp: Double?
        var hum: Double?
        var wind: Double?

        if let cw = dict["current_weather"] as? [String: Any] {
            temp = numberFromAny(cw["temperature"]) ?? numberFromAny(cw["temperature_2m"])
            wind = numberFromAny(cw["windspeed"]) ?? numberFromAny(cw["wind_speed_10m"]) ?? numberFromAny(cw["wind_speed"])
            // humidity usually not included here; try elsewhere
            hum = numberFromAny(cw["relativehumidity_2m"]) ?? numberFromAny(cw["relative_humidity_2m"])
        }

        if temp == nil {
            if let current = dict["current"] as? [String: Any] {
                temp = numberFromAny(current["temperature_2m"]) ?? numberFromAny(current["temperature"])
                hum = numberFromAny(current["relative_humidity_2m"]) ?? numberFromAny(current["relativehumidity_2m"])
                wind = numberFromAny(current["wind_speed_10m"]) ?? numberFromAny(current["windspeed"])
            }
        }

        if temp == nil {
            // maybe top-level keys
            temp = numberFromAny(dict["temperature_2m"]) ?? numberFromAny(dict["temperature"])
            hum = hum ?? numberFromAny(dict["relative_humidity_2m"]) ?? numberFromAny(dict["relativehumidity_2m"])
            wind = wind ?? numberFromAny(dict["wind_speed_10m"]) ?? numberFromAny(dict["windspeed"])
        }

        // Last attempt: try hourly arrays
        if (temp == nil || hum == nil || wind == nil),
           let hourly = dict["hourly"] as? [String: Any],
           let times = hourly["time"] as? [String] {
            // pick last index or match current_weather.time
            var index = times.count - 1
            if let cw = dict["current_weather"] as? [String: Any], let t = cw["time"] as? String, let idx = times.firstIndex(of: t) {
                index = idx
            }
            func extractHourly(_ key: String) -> Double? {
                if let arrD = hourly[key] as? [Double], arrD.indices.contains(index) { return arrD[index] }
                if let arrI = hourly[key] as? [Int], arrI.indices.contains(index) { return Double(arrI[index]) }
                return nil
            }
            temp = temp ?? extractHourly("temperature_2m") ?? extractHourly("temperature")
            hum = hum ?? extractHourly("relativehumidity_2m") ?? extractHourly("relative_humidity_2m")
            wind = wind ?? extractHourly("wind_speed_10m") ?? extractHourly("windspeed")
        }

        return WeatherModel(provider: "open-meteo", temperatureC: temp, humidityPct: hum, windSpeed: wind, rawJSON: dict)
    }

    private static func numberFromAny(_ v: Any?) -> Double? {
        if let d = v as? Double { return d }
        if let i = v as? Int { return Double(i) }
        if let s = v as? String, let d = Double(s) { return d }
        return nil
    }
    
    
 
}

extension WeatherService : WeatherServiceProtocol {
    
}
