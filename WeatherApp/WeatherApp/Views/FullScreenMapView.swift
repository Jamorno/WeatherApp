//
//  FullScreenMapView.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 27/9/2567 BE.
//

import SwiftUI

struct FullScreenMapView: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    @StateObject private var locationManager = LocationManager()
    
    @State private var selectedMapType = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            
            WeatherMapview(viewModel: viewModel)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    
                    //back button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "house.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                    
                    //drop down menu
                    Menu {
                        Button {
                            selectedMapType = "precipitation_new"
                            if let currentCity = viewModel.currentCity {
                                viewModel.fetchWeatherMapOverlay(lat: currentCity.latitude, lon: currentCity.longitude, mapType: selectedMapType)
                            }
                        } label: {
                            HStack {
                                Text("Precipitation")
                                Image(systemName: "umbrella.fill")
                            }
                        }
                        
                        Button {
                            selectedMapType = "temp_new"
                            if let currentCity = viewModel.currentCity {
                                viewModel.fetchWeatherMapOverlay(lat: currentCity.latitude, lon: currentCity.longitude, mapType: selectedMapType)
                            }
                        } label: {
                            Text("Temperature")
                            Image(systemName: "thermometer.sun")
                        }
                        
                        Button {
                            selectedMapType = "wind_new"
                            if let currentCity = viewModel.currentCity {
                                viewModel.fetchWeatherMapOverlay(lat: currentCity.latitude, lon: currentCity.longitude, mapType: selectedMapType)
                            }
                        } label: {
                            Text("Wind Speed")
                            Image(systemName: "wind")
                        }
                    } label: {
                        mapTypeTilte(for: selectedMapType)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                            .foregroundStyle(.black)
                    }
                }
                Spacer()
            }
            .padding()
            .onAppear {
                if let currentCity = viewModel.currentCity {
                    viewModel.fetchWeatherMapOverlay(lat: currentCity.latitude, lon: currentCity.longitude, mapType: selectedMapType)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    func mapTypeTilte(for mapType: String) -> Image{
        switch mapType {
        case "precipitation_new":
            return Image(systemName: "cloud.rain.circle.fill")
        case "temp_new":
            return Image(systemName: "thermometer.sun.circle.fill")
        case "wind_new":
            return Image(systemName: "wind.circle.fill")
        default:
            return Image(systemName: "map.circle.fill")
        }
    }
}

#Preview {
    FullScreenMapView(viewModel: WeatherViewModel())
}
