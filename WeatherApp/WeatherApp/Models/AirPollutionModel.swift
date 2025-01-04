//
//  AirPollutionModel.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 23/9/2567 BE.
//

import Foundation

struct AirPollutionResponse: Codable {
    let list: [PollutionData]
}

struct PollutionData: Codable {
    let main: AirQualityIndex
    let components: AirComponents
}

struct AirQualityIndex: Codable {
    let aqi: Int
}

struct AirComponents: Codable {
    let co: Double
    let no: Double
    let no2: Double
    let o3: Double
    let so2: Double
    let pm2_5: Double
    let pm10: Double
}
