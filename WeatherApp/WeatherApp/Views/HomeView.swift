//
//  HomeView.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 20/9/2567 BE.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel = WeatherViewModel()
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var search: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    //top feature search and current weather
                    VStack {
                        //search location button
                        HStack {
                            HStack {
                                TextField("", text: $search, prompt: Text("Search City").foregroundStyle(.black.opacity(0.2)))
                                    .padding(.horizontal)
                                    .foregroundStyle(.black)
                                Button {
                                    viewModel.fetchCityWeather(for: search)
                                    search = ""
                                } label: {
                                    Image(systemName: "magnifyingglass.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                        .foregroundStyle(.black)
                                }
                            }
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke(lineWidth: 0.5)
                                    .foregroundStyle(.black.opacity(0.2))
                            }
                            
                            //back to current location
                            Button {
                                if let location = locationManager.location {
                                    viewModel.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                                }
                                search = ""
                            } label: {
                                Image(systemName: "location.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        //show current weather
                        if let location = locationManager.location {
                            HStack() {
                                
                                VStack(alignment: .leading) {
                                    Text(viewModel.cityName)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    Text(viewModel.tempurture)
                                        .font(.system(size: 50))
                                        .fontWeight(.bold)
                                    Text(viewModel.weatherDescription)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                Image(systemName: viewModel.weatherIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color("shadow"), radius: 5, x: 5, y: 5)
                            }
                            .foregroundStyle(Color("secondary"))
                            .onAppear {
                                print("Location found: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                                viewModel.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                            }
                        } else {
                            Text("Searh Location...")
                                .font(.headline)
                        }
                        
                        //air pollution
                        AirPollutionView(viewModel: viewModel)
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        RoundedCorner(radius: 15, corners: [.topLeft, .topRight])
                            .stroke(Color("background"), lineWidth: 4)
                            .shadow(color: Color("shadow"), radius: 5, x: 5, y: 5)
                            .clipShape(RoundedCorner(radius: 25, corners: [.topLeft, .topRight]))
                            .shadow(color: Color("light"), radius: 4, x: -5, y: -5)
                            .ignoresSafeArea()
                        
                        //feature forecast, map
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack {
                                VStack {
                                    //hour forecast view
                                    HourForecastView(viewModel: viewModel)
                                        .background(Color("secondary"))
                                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                    
                                    //forecast view
                                    ForecastView(viewModel: viewModel)
                                    
                                    //map view
                                    Mapview(viewModel: viewModel)
                                }
                                .padding()
                            }
                        }
                    }
                    .padding(.vertical)
                    .ignoresSafeArea()
                }
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView()
}
