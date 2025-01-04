//
//  HourForecastView.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 28/9/2567 BE.
//

import SwiftUI

struct HourForecastView: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("HOURLY FORECAST")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.forward.2")
            }
            .foregroundStyle(Color("background"))
            .padding()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 20) {
                    ForEach(viewModel.getUpcomingForecasts().prefix(12), id: \.id) { forecast in
                        VStack(alignment: .center) {
                            let formattedTime = viewModel.formatTime(from: forecast.dt, timezoneOffset: viewModel.timeZoneOffset)
                            Text(formattedTime)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(width: 50)
                            Text("\(forecast.main.temp, specifier: "%.0f")°")
                                .font(.headline)
                                .frame(width: 50)
                            Image(systemName: viewModel.getWeatherIcon(from: forecast.weather.first?.icon ?? ""))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                        }
                    }
                }
                .foregroundStyle(Color("background"))
                .padding()
                .onAppear {
                    viewModel.fetch5DayWeather(lat: 13.75, lon: 100.5167)
                }
            }
        }
    }
}

#Preview {
    HourForecastView(viewModel: WeatherViewModel())
}
