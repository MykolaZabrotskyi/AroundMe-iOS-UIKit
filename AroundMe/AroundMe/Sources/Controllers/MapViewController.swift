//
//  MapViewController.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 16.02.2026.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

final class MapViewController: UIViewController {
    
    private let mainView = MapView()
    
    private let locationManager = CLLocationManager()
    private let placesService = PlacesService()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            handleAuthorizationStatus(locationManager.authorizationStatus)
        }
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            mainView.updateMyLocationEnabled(true)
        case .denied, .restricted:
            showAlert(title: "Access to geolocation is restricted", message: "To allow the app to find places around you, allow location access in settings.")
        default: break
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        locationManager.stopUpdatingLocation()
        
        mainView.moveCameraToUser(location.coordinate)
        
        placesService.searchNearby(at: location.coordinate) { [weak self] result in
            switch result {
            case .success(let places):
                self?.mainView.renderMarkers(for: places)
            case .failure(let error):
                self?.showAlert(title: "Couldn't find places nearby", message: "\(error.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        showAlert(title: "An error occurred related to geolocation", message: "\(error.localizedDescription)")
    }
}

private extension MapViewController {
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
}
