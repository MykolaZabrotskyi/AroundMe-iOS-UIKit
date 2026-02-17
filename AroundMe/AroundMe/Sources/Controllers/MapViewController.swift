//
//  MapViewController.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 16.02.2026.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    private var mainView: MapView {
        return self.view as! MapView
    }
    
    private let locationManager = CLLocationManager()
    
    override func loadView() {
        self.view = MapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            let a = 1
            // тут буде логіка алерту, коли юзер відхилить або місклікне на денай
        default: break
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        mainView.mapView.isMyLocationEnabled = true
        mainView.moveCameraToUser(location.coordinate)
        
        locationManager.stopUpdatingLocation()
    }
    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        // Logic
//    }
}
