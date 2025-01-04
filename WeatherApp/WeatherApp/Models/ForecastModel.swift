//
//  ForecastModel.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 22/9/2567 BE.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [Forecast]
    let city: CityInfo
}

struct CityInfo: Codable {
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

struct Forecast: Codable, Identifiable {
    var id: UUID { UUID() }
    let dt: Int
    let main: ForecastMain
    let weather: [WeatherCondition]
}

struct ForecastMain: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
}

struct WeatherCondition: Codable {
    let main: String
    let description: String
    let icon: String
}
