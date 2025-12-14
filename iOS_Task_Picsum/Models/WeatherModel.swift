import Foundation

struct WeatherModel {
    let provider: String
    let temperatureC: Double?
    let humidityPct: Double?
    let windSpeed: Double?
    let rawJSON: [String: Any]?
}

