//
//  AirPollutionView.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 23/9/2567 BE.
//

import SwiftUI

struct AirPollutionView: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    
    @State private var showAirpollutionDetail = false
    @State private var showWindSpeedDetail = false
    @State private var showSnowDeatil = false
    @State private var showRainDeatil = false
    
    var body: some View {
        HStack {
            //wind, snow, rain view
            if !showAirpollutionDetail && !showWindSpeedDetail && !showSnowDeatil && !showRainDeatil {
                HStack {
                    ExtractedWindSnowRainView(imageName: "wind", fetchTitle: "\(viewModel.windSpeed)", unit: "m/s")
                    
                    ExtractedWindSnowRainView(imageName: "snowflake", fetchTitle: "\(viewModel.snow)", unit: "mm")
                    
                    ExtractedWindSnowRainView(imageName: "cloud.rain.fill", fetchTitle: "\(viewModel.rain)", unit: "mm")
                }
            }
            
            //pollution view
            if let pollution = viewModel.airPollution {
                let aqi = pollution.list.first?.main.aqi ?? 0
                let airQualityDescription = viewModel.getAirQualityDescription(aqi: aqi)
                let airQuarlityColor = viewModel.getColorForAirQuality(api: aqi)
                
                if !showAirpollutionDetail {
                    VStack {
                        Text("Air Quality")
                            .font(.callout)
                        Text("\(airQualityDescription)")
                            .font(.headline)
                        Image(systemName: "hand.tap.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                    }
                    .padding()
                    .frame(height: 100)
                    .background(airQuarlityColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    .onTapGesture {
                        withAnimation(.snappy) {
                            showAirpollutionDetail.toggle()
                        }
                    }
                } else {
                    HStack {
                        VStack {
                            Text("so2:  ").foregroundStyle(.black.opacity(0.3)) +
                            Text("\(pollution.list.first?.components.so2 ?? 0, specifier: "%.2f")")
                                .foregroundStyle(.black)
                            
                            Divider()
                            
                            Text("PM2.5:  ").foregroundStyle(.black.opacity(0.3)) +
                            Text("\(pollution.list.first?.components.pm2_5 ?? 0, specifier: "%.0f")")
                                .foregroundStyle(.black)
                        }
                        .font(.headline)
                        .frame(height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(.black.opacity(0.2))
                        }

                        VStack {
                            Text("o3:  ").foregroundStyle(.black.opacity(0.3)) +
                            Text("\(pollution.list.first?.components.o3 ?? 0, specifier: "%.0f")")
                                .foregroundStyle(.black)
                                
                            Divider()
                            
                            Text("no2:  ").foregroundStyle(.black.opacity(0.3)) +
                            Text("\(pollution.list.first?.components.no2 ?? 0, specifier: "%.0f")")
                                .foregroundStyle(.black)
                                
                        }
                        .font(.headline)
                        .frame(height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(.black.opacity(0.2))
                        }
                        
                        VStack {
                            Text("PM10:  ").foregroundStyle(.black.opacity(0.3)) +
                            Text("\(pollution.list.first?.components.pm10 ?? 0, specifier: "%.0f")")
                                .foregroundStyle(.black)
                            
                            Divider()
                            
                            Text("CO:  ").foregroundStyle(.black.opacity(0.3)) +
                            Text("\(pollution.list.first?.components.co ?? 0, specifier: "%.0f")")
                                .foregroundStyle(.black)
                        }
                        .font(.headline)
                        .frame(height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 25.0)
                                .stroke(lineWidth: 1.0)
                                .foregroundStyle(.black.opacity(0.2))
                        }
                    }
                    .onTapGesture {
                        withAnimation(.snappy) {
                            showAirpollutionDetail.toggle()
                        }
                    }
                }
            } else {
                Text("Loading air quality data...")
            }
        }
        .onAppear {
            viewModel.fetchWeather(lat: 35, lon: 35)
        }
    }
}

#Preview {
    AirPollutionView(viewModel: WeatherViewModel())
}

struct ExtractedWindSnowRainView: View {
    
    var imageName: String
    var fetchTitle: String
    var unit: String
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 28,height: 28)
            Text(fetchTitle)
                .font(.headline)
            Text(unit)
                .font(.headline)
        }
        .foregroundStyle(Color("background"))
        .padding()
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color("verypoor"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
