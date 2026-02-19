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
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        
        mainView.moveCameraToUser(location.coordinate)
        
        placesService.searchNearby(at: location.coordinate) { [weak self] result in
            switch result {
            case .success(let places):
                self?.mainView.renderMarkers(for: places)
            case .failure(let error):
                self?.showAlert(
                    title: Constants.Alert.PlaceServiceFailure.title,
                    message: (error.localizedDescription)
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        showAlert(
            title: Constants.Alert.LocationManagerFailed.title,
            message: error.localizedDescription
        )
    }
}

private extension MapViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: Constants.Alert.Action.title, style: .default)
        alert.addAction(okAction)
        
        self.present(alert, animated: true)
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            handleAuthorizationStatus(locationManager.authorizationStatus)
        }
    }
    
    func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            mainView.updateMyLocationEnabled(true)
            
        case .denied, .restricted:
            showAlert(
                title: Constants.Alert.AutorizationDenied.title,
                message: Constants.Alert.AutorizationDenied.message
            )
            
        default: break
        }
    }
    
}

private extension MapViewController {
    
    enum Constants {
        enum Alert {
            enum Action {
                static let title = "OK"
            }
            
            enum PlaceServiceFailure {
                static let title = "Couldn't find places nearby"
            }
            
            enum LocationManagerFailed {
                static let title = "An error occurred related to geolocation"
            }
            
            enum AutorizationDenied {
                static let title = "Access to geolocation is restricted"
                static let message = "To allow the app to find places around you, allow location access in settings."
            }
        }
    }
    
}
