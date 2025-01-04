//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 20/9/2567 BE.
//

import Foundation

class WeatherService {
    lazy var apiKey: String = getAPIKey()
    
    //get api
    func getAPIKey() -> String {
        if let url = Bundle.main.url(forResource: "API", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
            return plist["API_KEY"] as? String ?? ""
        }
        return ""
    }
    
    //for weather current location api from openweather
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (WeatherResponse?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let weatherRsponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherRsponse)
            } catch {
                print("Error to fetch JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        .resume()
    }
    
    //for search weather of city
    func fetchCityWeather(city: String, completion: @escaping (WeatherResponse?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(weatherResponse)
            } catch {
                print("Error to fetch JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        .resume()
    }
    
    //for 5 day forecast weather
    func fetch5DayForecast(lat: Double, lon: Double, completion: @escaping (ForecastResponse?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                print("Decoded successfully: \(forecastResponse.list)")
                completion(forecastResponse)
            } catch {
                print("Error decoding forecast data: \(error)")
                completion(nil)
            }
        }
        .resume()
    }
    
    //for air pollution
    func fetchAirPollution(lat: Double, lon: Double, completion: @escaping (AirPollutionResponse?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch air pollution data: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                let airPollutionResponse = try JSONDecoder().decode(AirPollutionResponse.self, from: data)
                completion(airPollutionResponse)
            } catch {
                print("Failed to decode air pollution data: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
