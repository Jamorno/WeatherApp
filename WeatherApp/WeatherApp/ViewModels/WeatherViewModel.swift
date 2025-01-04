//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 20/9/2567 BE.
//

import Foundation
import CoreLocation
import Combine
import MapKit
import SwiftUI


class WeatherViewModel: ObservableObject {
    @Published var cityName: String = ""
    @Published var tempurture: String = ""
    @Published var weatherDescription: String = ""
    @Published var humidity: String = ""
    @Published var windSpeed: String = ""
    @Published var rain: String = ""
    @Published var snow: String = ""
    @Published var weatherIcon: String = ""
    
    @Published var timeZoneOffset: Int = 0
    
    @Published var forecast: [Forecast] = []
    
    @Published var coordinate: CLLocationCoordinate2D?
    
    @Published var airPollution: AirPollutionResponse? //for air pollution
    
    //for weather map
    @Published var mapOverlay: MKTileOverlay?
    @Published var region = MKCoordinateRegion()
    @Published var selectedMapType: String = "precipitation_new"
    @Published var currentCity: City?
    
    private let weatherService = WeatherService()
    
    //fetch weather current location
    func fetchWeather(lat: Double, lon: Double) {
        weatherService.fetchWeather(lat: lat, lon: lon) {weatherResponse in
            guard let weatherResponse = weatherResponse else {
                print("No weather data received")
                return
            }
            
            DispatchQueue.main.async {
                self.cityName = weatherResponse.name
                self.tempurture = "\(weatherResponse.main.temp)°c"
                self.weatherDescription = weatherResponse.weather.first?.description.capitalized ?? ""
                self.humidity = "Humidity: \(weatherResponse.main.humidity)%"
                self.weatherIcon = self.getWeatherIcon(from: weatherResponse.weather.first?.icon ?? "")
                self.coordinate = CLLocationCoordinate2D(latitude: weatherResponse.coord.lat, longitude: weatherResponse.coord.lon)
                
                self.fetch5DayWeather(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon)
                
                self.fetchAirPollution(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon)
                self.windSpeed = "\(weatherResponse.wind.speed)"
                if let rain = weatherResponse.rain?.oneHour {
                    self.rain = "\(rain)"
                } else {
                    self.rain = "0"
                }
                if let snow = weatherResponse.snow {
                    self.snow = "\(snow)"
                } else {
                    self.snow = "0"
                }
                
                //for map
                self.fetchWeatherMapOverlay(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon, mapType: self.selectedMapType)
                self.updateCity(name: weatherResponse.name, lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon)
            }
        }
    }
    
    //fetch weather for city
    func fetchCityWeather(for city: String) {
        weatherService.fetchCityWeather(city: city) {weatherResponse in
            guard let weatherResponse = weatherResponse else {
                return
            }
            
            DispatchQueue.main.async {
                self.cityName = weatherResponse.name
                self.tempurture = "\(weatherResponse.main.temp)°c"
                self.weatherDescription = weatherResponse.weather.first?.description.capitalized ?? ""
                self.humidity = "Humidity: \(weatherResponse.main.humidity)%"
                self.weatherIcon = self.getWeatherIcon(from: weatherResponse.weather.first?.icon ?? "")
                self.coordinate = CLLocationCoordinate2D(latitude: weatherResponse.coord.lat, longitude: weatherResponse.coord.lon)
                
                self.fetch5DayWeather(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon)
                
                self.fetchAirPollution(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon)
                self.windSpeed = "\(weatherResponse.wind.speed)"
                if let rain = weatherResponse.rain?.oneHour {
                    self.rain = "\(rain)"
                } else {
                    self.rain = "0"
                }
                if let snow = weatherResponse.snow {
                    self.snow = "\(snow)"
                } else {
                    self.snow = "0"
                }
                
                //for map
                self.fetchWeatherMapOverlay(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon, mapType: self.selectedMapType)
                self.updateCity(name: weatherResponse.name, lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon)
            }
        }
    }
    
    //fetch 5 day forecast weather
    func fetch5DayWeather(lat: Double, lon: Double) {
        weatherService.fetch5DayForecast(lat: lat, lon: lon) { forecastResponse in
            guard let forecastResponse = forecastResponse else {
                print("No forecast data received")
                return
            }
            DispatchQueue.main.async {
                self.forecast = forecastResponse.list
                self.timeZoneOffset = forecastResponse.city.timezone
            }
        }
    }
    
    func getDailyForecast(forecastList: [Forecast]) -> [Forecast] {
        var dailyForecasts: [Forecast] = []
        var previousDate: Date?

        for forecast in forecastList {
            let forecastDate = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            let calendar = Calendar.current
            let currentDay = calendar.component(.day, from: forecastDate)

            if let prevDate = previousDate {
                let previousDay = calendar.component(.day, from: prevDate)
                if currentDay != previousDay {
                    dailyForecasts.append(forecast)
                }
            } else {
                dailyForecasts.append(forecast)
            }

            previousDate = forecastDate
        }
        
        return dailyForecasts
    }
    
    func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        }
        
        dateFormatter.dateFormat = "EEE"
        
        return dateFormatter.string(from: date)
    }
    
    func formatTime(from timestamp: Int, timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)

        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func getUpcomingForecasts() -> [Forecast] {
        let currentDate = Date()

        // ดึงพยากรณ์อากาศที่มากกว่าหรือเท่ากับเวลาปัจจุบัน
        var upcomingForecasts = forecast.filter { forecast in
            let forecastDate = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            return forecastDate >= currentDate
        }
        
        // ตรวจสอบว่ามีพยากรณ์ก่อนหน้านี้หนึ่งขั้นตอนไหม ถ้ามีให้นำมาใส่ที่ตำแหน่งเริ่มต้น
        if let previousForecastIndex = forecast.firstIndex(where: { forecast in
            let forecastDate = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            return forecastDate < currentDate
        }) {
            let previousForecast = forecast[previousForecastIndex]
            upcomingForecasts.insert(previousForecast, at: 0)
        }

        return upcomingForecasts
    }
    
    //fetch air pollution
    func fetchAirPollution(lat: Double, lon: Double) {
        print("Fetching air pollution for lat: \(lat), lon: \(lon)")
        
        weatherService.fetchAirPollution(lat: lat, lon: lon) { [weak self] airPollutionResponse in
            DispatchQueue.main.async {
                self?.airPollution = airPollutionResponse
            }
        }
    }
    
    func getAirQualityDescription(aqi: Int) -> String {
        switch aqi {
        case 1:
            return "Good"
        case 2:
            return "Fair"
        case 3:
            return "Moderate"
        case 4:
            return "Poor"
        case 5:
            return "Very Poor"
        default:
            return "Unknow"
        }
    }
    
    func getColorForAirQuality(api: Int) -> Color {
        switch api {
        case 1:
            return Color("good")
        case 2:
            return Color("primary")
        case 3:
            return Color("moderate")
        case 4:
            return Color("poor")
        case 5:
            return Color("verypoor")
        default:
            return Color.gray
        }

    }
    
    //fetch weather map
    func fetchWeatherMapOverlay(lat: Double, lon: Double, mapType: String) {
        let apiKey = weatherService.apiKey
        let template = "https://tile.openweathermap.org/map/\(mapType)/{z}/{x}/{y}.png?appid=\(apiKey)"
        let overLay = MKTileOverlay(urlTemplate: template)
        overLay.canReplaceMapContent = false
        
        DispatchQueue.main.async {
            self.mapOverlay = overLay
            self.updateRegionFor(location: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            print("Overlay updated with map type: \(mapType)")        }
    }
    
    //update location for map for zoom in or zoom out
    func updateRegionFor(location: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
    func updateCity(name: String, lat: Double, lon: Double) {
        self.currentCity = City(name: name, latitude: lat, longitude: lon)
        print("Updated current city to: \(name) at lat: \(lat), lon: \(lon)")
    }
    
    //icon image from openweather -> systemImage
    func getWeatherIcon(from iconCode: String) -> String {
        switch iconCode {
        case "01d": return "sun.min"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "cloud.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark"
        }
    }
}
