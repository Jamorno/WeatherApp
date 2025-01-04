//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Jamorn Suttipong on 20/9/2567 BE.
//

import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //request notification authorization here
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("User granted notifications permission")
            } else {
                print("User denied notifications permission")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location access not authorized.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.first {
            location = newLocation
            print("Updated location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
            locationManager.stopUpdatingLocation()
        } else {
            print("No location received.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error fetch location: \(error.localizedDescription)")
    }
    
    //alert weather danger in location
    func startMonitoring(location: CLLocation) {
        let regionRadius = 100.0
        let region = CLCircularRegion(center: location.coordinate, radius: regionRadius, identifier: "TargetRegion")
        
        //alert from in and out of location
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
    }
    
    func sendNotification(_ body: String) {
        let content = UNMutableNotificationContent()
        content.title = "Your location"
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendNotification("You are in location")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        sendNotification("Out of location")
    }
}
