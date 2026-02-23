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
    // MARK: - Properties
    private let mainView = MapView()
    
    private let locationManager = CLLocationManager()
    private let placesService = PlacesService()
    
    private var fetchedPlaces: [PlaceModel] = []
    
    // MARK: - Lifecycle
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
                self?.mainView.moveCameraToPlace(coordinate)
                self?.mainView.openMarkerSnippet(at: coordinate)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - Private Methods
private extension MapViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: Constant.Alert.Action.title, style: .default)
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
                title: Constant.Alert.Title.authorizationDenied,
                message: Constant.Alert.Message.authorizationDenied
            )
            
        default: break
        }
    }
}

// MARK: - CLLocationManagerDelegate
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
                    title: Constant.Alert.Title.placeServiceFailure,
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
            title: Constant.Alert.Title.locationManagerFailure,
            message: error.localizedDescription
        )
    }
}

// MARK: - Constants
private extension MapViewController {
    enum Constant {
        enum Alert {
            enum Action {
                static let title: String = "OK"
            }
            
            enum Title {
                static let placeServiceFailure: String = "Couldn't find places nearby"
                static let locationManagerFailure: String = "An error occurred related to geolocation"
                static let authorizationDenied: String = "Access to geolocation is restricted"
            }
            
            enum Message {
                static let authorizationDenied: String = "To allow the app to find places around you, allow location access in settings."
            }
        }
    }
}
