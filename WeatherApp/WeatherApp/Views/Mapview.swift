//
//  Mapview.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 26/9/2567 BE.
//

import SwiftUI
import MapKit

struct WeatherMapview: UIViewRepresentable {
    
    @ObservedObject var viewModel: WeatherViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        
        if let overlay = viewModel.mapOverlay {
            mapView.addOverlay(overlay)
        }
        mapView.setRegion(viewModel.region, animated: true)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        
        if let overlay = viewModel.mapOverlay {
            mapView.addOverlay(overlay)
        }
        
        mapView.setRegion(viewModel.region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: WeatherMapview
        
        init(parent: WeatherMapview) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let titleOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: titleOverlay)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct Mapview: View {
    
    @ObservedObject var viewModel: WeatherViewModel
    @StateObject private var locationManager = LocationManager()
    
    @State private var showFullScreenMap = false
    @State private var selectedMapType = "precipitation_new"
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Image(systemName: "umbrella.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.black)
                    Text("PRECIPITATION")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
                NavigationLink(destination: FullScreenMapView(viewModel: viewModel)) {
                    WeatherMapview(viewModel: viewModel)
                        .frame(height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
            }
            .padding(.vertical)
            .onAppear {
                if let currentCity = viewModel.currentCity {
                    viewModel.fetchWeatherMapOverlay(lat: currentCity.latitude, lon: currentCity.longitude, mapType: selectedMapType)
                }
            }
        }
    }
}

#Preview {
    Mapview(viewModel: WeatherViewModel())
}
