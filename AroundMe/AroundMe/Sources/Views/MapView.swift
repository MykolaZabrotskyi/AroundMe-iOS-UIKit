//
//  MapView.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 17.02.2026.
//

import UIKit
import GoogleMaps
import GooglePlaces

final class MapView: UIView {
    // MARK: - Properties
    
    var onListButtonTapped: (() -> Void)?
    var onLocationButtonTapped: (() -> Void)?
    
    private var displayedMarkers: [GMSMarker] = []
    
    // MARK: - UI Components
    
    private let mapView: GMSMapView = {
        let options = GMSMapViewOptions()
        options.backgroundColor = .systemBackground
        
        let map = GMSMapView(options: options)
        map.mapType = .normal
        map.isBuildingsEnabled = false
        map.settings.rotateGestures = false
        map.accessibilityElementsHidden = false
        
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        applyMapStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    
    func updateMyLocationEnabled(_ enabled: Bool) {
        mapView.isMyLocationEnabled = enabled
    }
    
    func moveCameraToUser(_ location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: Constant.zoomCameraOnUser)
        mapView.animate(to: camera)
    }
    
    func moveCameraToPlace(_ location: CLLocationCoordinate2D) {
        guard let userCoordinate = mapView.myLocation?.coordinate else {
            let camera = GMSCameraPosition.camera(withTarget: location, zoom: Constant.zoomCameraOnUser)
            mapView.animate(to: camera)
            return
        }
        
        let bounds = GMSCoordinateBounds(coordinate: userCoordinate, coordinate: location)
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: Constant.cameraPadding)
        mapView.animate(with: update)
    }
    
    func openMarkerSnippet(at location: CLLocationCoordinate2D) {
        let markerToSelect = displayedMarkers.first { marker in
            marker.position.latitude == location.latitude &&
            marker.position.longitude == location.longitude
        }
        
        mapView.selectedMarker = markerToSelect
    }
    
    func renderMarkers(for places: [PlaceModel]) {
        mapView.clear()
        displayedMarkers.removeAll()
        
        for place in places {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            marker.snippet = place.fullAddress
            marker.appearAnimation = .pop
            marker.map = mapView
            
            displayedMarkers.append(marker)
        }
    }
}

// MARK: - Private Methods

private extension MapView {
    // MARK: - Actions
    
    @objc func locationButtonTapped() {
        if let coordinate = mapView.myLocation?.coordinate {
            moveCameraToUser(coordinate)
        } else {
            onLocationButtonTapped?()
        }
    }
    
    @objc func listButtonTapped() {
        onListButtonTapped?()
    }
    
    // MARK: - Setup / Configuration
    
    func setupLayout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mapView)
        addSubview(buttonsVerticalStackView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            buttonsVerticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constant.Button.layoutPadding),
            buttonsVerticalStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Constant.Button.layoutPadding),
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
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: url)
        } catch {
            assertionFailure("Failed to apply map style: \(error.localizedDescription)")
        }
    }
}

// MARK: - Constants

private extension MapView {
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
