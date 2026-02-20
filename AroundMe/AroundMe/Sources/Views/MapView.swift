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
        configuration.image = UIImage(systemName: Constants.Buttons.SystemImages.list)
        configuration.imagePlacement = .all
        configuration.preferredSymbolConfigurationForImage = Constants.Buttons.systemImageConfig
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var onListButtonTapped: (() -> Void)?
    
    private lazy var locationButton: UIButton = {
        var configuration = UIButton.Configuration.glass()
        configuration.image = UIImage(systemName: Constants.Buttons.SystemImages.location)
        configuration.imagePlacement = .all
        configuration.preferredSymbolConfigurationForImage = Constants.Buttons.systemImageConfig
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var onLocationButtonTapped: (() -> Void)?
    
    private lazy var buttonsVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [listButton, locationButton])
        stackView.axis = .vertical
        stackView.spacing = Constants.Buttons.spaceBetweenButtons
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        applyMapStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMyLocationEnabled(_ enabled: Bool) {
        mapView.isMyLocationEnabled = enabled
    }
    
    func moveCameraToUser(_ location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: Constants.zoomCameraOnUser)
        mapView.animate(to: camera)
    }
    
    func renderMarkers(for places: [PlaceModel]) {
        mapView.clear()
        
        for place in places {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            marker.snippet = place.fullAddress
            marker.appearAnimation = .pop
            marker.map = mapView
        }
    }
}

private extension MapView {
    
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
    
    func setupLayout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mapView)
        addSubview(buttonsVStackView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            buttonsVStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.Buttons.layoutPadding),
            buttonsVStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Constants.Buttons.layoutPadding),
            buttonsVStackView.widthAnchor.constraint(equalToConstant: Constants.Buttons.sizeOfButtons),
            
            listButton.heightAnchor.constraint(equalToConstant: Constants.Buttons.sizeOfButtons),
            
            locationButton.heightAnchor.constraint(equalToConstant: Constants.Buttons.sizeOfButtons)
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

private extension MapView {
    
    enum Constants {
        static let zoomCameraOnUser: Float = 13.0
        
        enum Buttons {
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
