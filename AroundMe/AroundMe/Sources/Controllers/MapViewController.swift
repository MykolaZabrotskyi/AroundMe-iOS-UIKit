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
    
    private var fetchedPlaces: [PlaceModel] = []
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        
        mainView.onLocationButtonTapped = { [weak self] in
            self?.locationManager.startUpdatingLocation()
        }
        
        mainView.onListButtonTapped = { [weak self] in
            guard let self else {
                return
            }
            
            let listVC = ListViewController(places: self.fetchedPlaces)
            self.navigationController?.pushViewController(listVC, animated: true)
            
            listVC.onPlaceSelected = { [weak self] coordinate in
                self?.mainView.moveCameraToUser(coordinate)
                self?.navigationController?.popViewController(animated: true)
            }
        }
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
                self?.fetchedPlaces = places
                self?.mainView.renderMarkers(for: places)
                
            case .failure(let error):
                self?.showAlert(
                    title: Constants.Alerts.Titles.placeServiceFailure,
                    message: error.localizedDescription
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        
        showAlert(
            title: Constants.Alerts.Titles.locationManagerFailure,
            message: error.localizedDescription
        )
    }
}

private extension MapViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: Constants.Alerts.Action.title, style: .default)
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
                title: Constants.Alerts.Titles.authorizationDenied,
                message: Constants.Alerts.Messages.authorizationDenied
            )
            
        default: break
        }
    }
}

private extension MapViewController {
    
    enum Constants {
        
        enum Alerts {
            
            enum Action {
                static let title: String = "OK"
            }
            
            enum Titles {
                static let placeServiceFailure: String = "Couldn't find places nearby"
                static let locationManagerFailure: String = "An error occurred related to geolocation"
                static let authorizationDenied: String = "Access to geolocation is restricted"
            }
            
            enum Messages {
                static let authorizationDenied: String = "To allow the app to find places around you, allow location access in settings."
            }
        }
    }
}
