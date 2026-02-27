//
//  MapPresenter.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 27.02.2026.
//

import Foundation
import CoreLocation

protocol MapPresenterProtocol: AnyObject {
    func didTapListButton()
    func didUpdateLocation(_ location: CLLocation)
    func didFailLocation(with error: Error)
    func didChangeAuthorization(_ status: CLAuthorizationStatus)
}

final class MapPresenter {
    
    // MARK: - Properties
    
    weak var view: MapViewControllerProtocol?
    
    private let router: MapRouterProtocol
    private let placesService: PlacesService
    private var fetchedPlaces: [PlaceModel] = []
    
    struct Dependencies {
        let router: MapRouterProtocol
        let placesService: PlacesService
    }
    
    // MARK: - Init
    
    init(dependencies: Dependencies) {
        self.router = dependencies.router
        self.placesService = dependencies.placesService
    }
}

// MARK: - MapPresenterProtocol

extension MapPresenter: MapPresenterProtocol {
    func didTapListButton() {
        router.pushToList(with: fetchedPlaces)
    }
    
    func didUpdateLocation(_ location: CLLocation) {
        view?.moveCameraToUser(location.coordinate)
        
        placesService.searchNearby(at: location.coordinate) { [weak self] result in
            switch result {
            case .success(let places):
                self?.fetchedPlaces = places
                self?.view?.renderMarkers(for: places)
                
            case .failure(let error):
                self?.view?.showAlert(
                    title: Constant.Alert.Title.placeServiceFailure,
                    message: error.localizedDescription
                )
            }
        }
    }
    
    func didFailLocation(with error: Error) {
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        
        view?.showAlert(
            title: Constant.Alert.Title.locationManagerFailure,
            message: error.localizedDescription
        )
    }
    
    func didChangeAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            view?.updateMyLocationEnabled(true)
            
        case .denied, .restricted:
            view?.showAlert(
                title: Constant.Alert.Title.authorizationDenied,
                message: Constant.Alert.Message.authorizationDenied
            )
            
        default: break
        }
    }
}

// MARK: - Constants

private extension MapPresenter {
    enum Constant {
        enum Alert {
            enum Title {
                static let placeServiceFailure = "Couldn't find places nearby"
                static let locationManagerFailure = "An error occurred related to geolocation"
                static let authorizationDenied = "Access to geolocation is restricted"
            }
            enum Message {
                static let authorizationDenied = "To allow the app to find places around you, allow location access in settings."
            }
        }
    }
}
