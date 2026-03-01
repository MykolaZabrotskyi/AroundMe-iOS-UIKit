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

protocol MapViewControllerProtocol: AnyObject {
    func updateMyLocationEnabled(_ enabled: Bool)
    func moveCameraToUser(_ coordinate: CLLocationCoordinate2D)
    func moveCameraToPlace(_ coordinate: CLLocationCoordinate2D)
    func openMarkerSnippet(at coordinate: CLLocationCoordinate2D)
    func renderMarkers(for places: [PlaceModel])
    func showAlert(title: String, message: String)
}

final class MapViewController: UIViewController {
    
    // MARK: - Properties
    
    private var presenter: MapPresenterProtocol!
    
    private let locationManager = CLLocationManager()
    
    private var displayedMarkers: [GMSMarker] = []
    
    // MARK: - UI Components
    
    private let googleMapView: GMSMapView = {
        let options = GMSMapViewOptions()
        options.backgroundColor = .systemBackground
        
        let map = GMSMapView(options: options)
        map.mapType = .normal
        map.isBuildingsEnabled = false
        map.settings.rotateGestures = false
        map.accessibilityElementsHidden = false
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
    }()
    
    private lazy var listButton: UIButton = {
        var configuration = UIButton.Configuration.glass()
        configuration.image = UIImage(systemName: Constant.Button.SystemImages.list)
        configuration.imagePlacement = .all
        configuration.preferredSymbolConfigurationForImage = Constant.Button.systemImageConfig
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var locationButton: UIButton = {
        var configuration = UIButton.Configuration.glass()
        configuration.image = UIImage(systemName: Constant.Button.SystemImages.location)
        configuration.imagePlacement = .all
        configuration.preferredSymbolConfigurationForImage = Constant.Button.systemImageConfig
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var buttonsVerticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [listButton, locationButton])
        stackView.axis = .vertical
        stackView.spacing = Constant.Button.spaceBetweenButtons
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        applyMapStyle()
        setupLocationManager()
    }
    
    // MARK: - Internal Methods
    
    func inject(presenter: MapPresenterProtocol) {
        self.presenter = presenter
    }
}

// MARK: - Private Methods

private extension MapViewController {
    
    // MARK: - Actions
    
    @objc func locationButtonTapped() {
        if let coordinate = googleMapView.myLocation?.coordinate {
            moveCameraToUser(coordinate)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func listButtonTapped() {
        presenter.didTapListButton()
    }
    
    // MARK: - Setup/Configuration
    
    func setupLayout() {
        googleMapView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(googleMapView)
        view.addSubview(buttonsVerticalStackView)
        
        NSLayoutConstraint.activate([
            googleMapView.topAnchor.constraint(equalTo: view.topAnchor),
            googleMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            googleMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            googleMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonsVerticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constant.Button.layoutPadding),
            buttonsVerticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constant.Button.layoutPadding),
            buttonsVerticalStackView.widthAnchor.constraint(equalToConstant: Constant.Button.sizeOfButtons),
            
            listButton.heightAnchor.constraint(equalToConstant: Constant.Button.sizeOfButtons),
            
            locationButton.heightAnchor.constraint(equalToConstant: Constant.Button.sizeOfButtons)
        ])
    }
    
    func applyMapStyle() {
        guard let url = Bundle.main.url(forResource: "MapStyle", withExtension: "json") else {
            assertionFailure("MapStyle.json not found in bundle")
            
            return
        }
        
        do {
            googleMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: url)
        } catch {
            assertionFailure("Failed to apply map style: \(error.localizedDescription)")
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            presenter.didChangeAuthorization(locationManager.authorizationStatus)
        }
    }
}

// MARK: - MapViewControllerProtocol

extension MapViewController: MapViewControllerProtocol {
    func updateMyLocationEnabled(_ enabled: Bool) {
        googleMapView.isMyLocationEnabled = enabled
        if enabled {
            locationManager.startUpdatingLocation()
        }
    }
    
    func moveCameraToUser(_ coordinate: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: Constant.zoomCameraOnUser)
        googleMapView.animate(to: camera)
    }
    
    func moveCameraToPlace(_ coordinate: CLLocationCoordinate2D) {
        guard let userCoordinate = googleMapView.myLocation?.coordinate else {
            moveCameraToUser(coordinate)
            return
        }
        
        let bounds = GMSCoordinateBounds(coordinate: userCoordinate, coordinate: coordinate)
        let update = GMSCameraUpdate.fit(bounds, withPadding: Constant.cameraPadding)
        googleMapView.animate(with: update)
    }
    
    func openMarkerSnippet(at coordinate: CLLocationCoordinate2D) {
        let markerToSelect = displayedMarkers.first(where: { marker in
            marker.position.latitude == coordinate.latitude &&
            marker.position.longitude == coordinate.longitude
        })
        
        googleMapView.selectedMarker = markerToSelect
    }
    
    func renderMarkers(for places: [PlaceModel]) {
        googleMapView.clear()
        displayedMarkers.removeAll()
        
        for place in places {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            marker.snippet = place.fullAddress
            marker.appearAnimation = .pop
            marker.map = googleMapView
            displayedMarkers.append(marker)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        presenter.didChangeAuthorization(manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        locationManager.stopUpdatingLocation()
        presenter.didUpdateLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        presenter.didFailLocation(with: error)
    }
}

// MARK: - Constants

private extension MapViewController {
    enum Constant {
        static let zoomCameraOnUser: Float = 16.0
        static let cameraPadding: CGFloat = 150.0
        
        enum Button {
            static let systemImageConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            static let spaceBetweenButtons: CGFloat = 16.0
            static let sizeOfButtons: CGFloat = 70.0
            static let layoutPadding: CGFloat = -20.0
            
            enum SystemImages {
                static let list = "list.bullet"
                static let location = "location"
            }
        }
    }
}
