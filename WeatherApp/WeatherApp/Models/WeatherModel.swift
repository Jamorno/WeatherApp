//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 20/9/2567 BE.
//

import Foundation

//import data from open weather api and usr Codable -> Json -> model swift
struct WeatherResponse: Codable {
    let coord: Coordinate
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let rain: Rain?
    let snow: Snow?
}

struct Coordinate: Codable {
    let lat: Double
    let lon: Double
}

struct Main: Codable {
    let temp: Double
    let humidity: Double
}

struct Rain: Codable {
    let oneHour: Double?

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

struct Snow: Codable {
    let oneHour: Double?

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

struct Wind: Codable {
    let speed: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}
