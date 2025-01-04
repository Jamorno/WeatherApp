//
//  ForecastView.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 22/9/2567 BE.
//

import SwiftUI

struct ForecastView: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image(systemName: "calendar")
                Text("DAY FORECAST")
                    .font(.headline)
                
                Spacer()
            }
            .foregroundStyle(.black)
            .padding(.top)
            
            Divider()
            
            ForEach(viewModel.getDailyForecast(forecastList: Array(viewModel.forecast.prefix(40))), id: \.id) { forecast in
                HStack {
                    HStack(alignment: .center, spacing: 16) {
                        Text(viewModel.formatDate(from: forecast.dt))
                            .fontWeight(.bold)
                            .frame(width: 60, alignment: .leading)
                        Image(systemName: viewModel.getWeatherIcon(from: forecast.weather.first?.icon ?? ""))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 42, height: 42)
                        Text("\(forecast.main.temp_min, specifier: "%.2f")°")
                            .foregroundStyle(.gray)
                            .frame(width: 60, alignment: .leading)
                        Image(systemName: "minus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 30)
                        Text("\(forecast.main.temp_max, specifier: "%.2f")°")
                            .frame(width: 60, alignment: .trailing)
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                }
                Divider()
            }
        }
        .onAppear {
            print("ForecastView: forecast count = \(viewModel.forecast.count)")
            viewModel.fetch5DayWeather(lat: viewModel.coordinate?.latitude ?? 0, lon: viewModel.coordinate?.longitude ?? 0)
        }
    }
}

#Preview {
    ForecastView(viewModel: WeatherViewModel())
}
