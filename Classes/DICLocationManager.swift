//
//  DICLocationManager.swift
//  DeviceInfoCollector
//
//  Created by Ahsan on 21/06/2023.
//

import CoreLocation
import UIKit

public class DICLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var isLocationAuthorized: Bool = false
    @Published var loc: DeviceLocation?
    
    public override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
           if #available(iOS 14.0, *) {
               let authorizationStatus = locationManager.authorizationStatus
               handleAuthorizationStatus(authorizationStatus)
           } else {
               let authorizationStatus = CLLocationManager.authorizationStatus()
               handleAuthorizationStatus(authorizationStatus)
           }
       }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            // Handle authorization status not granted
            loc = DeviceLocation(location: "Location permission denied")
            locationManager.requestWhenInUseAuthorization()
            
            // Display an alert or show a message to the user
            let alertController = UIAlertController(
                title: "Location Permission Denied",
                message: "Please enable location permission for this app in Settings to use the location feature.",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // Present the alert to the user
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        } else {
            loc = DeviceLocation(location: "Location permission not determined")
            locationManager.startUpdatingLocation()
        }
    }
    
    // CLLocationManagerDelegate methods
    
    private func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            let authorizationStatus = locationManager.authorizationStatus
            isLocationAuthorized = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        } else {
            let authorizationStatus = CLLocationManager.authorizationStatus()
            isLocationAuthorized = authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        }
        
        if isLocationAuthorized {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            // Handle authorization status not granted
            print("Ask for location")
        }
    }
    
    
    private func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let accuracy = location.horizontalAccuracy
        
        currentLocation = location
        loc = DeviceLocation(location: "Latitude: \(latitude)\nLongitude: \(longitude)\nAccuracy: \(accuracy) meters")
        // Stop updating location if needed
        locationManager.stopUpdatingLocation()
    }
}

