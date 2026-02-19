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
    
    private lazy var mapView: GMSMapView = {
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
        
        configuration.image = UIImage(systemName: "list.bullet")
        configuration.imagePlacement = .all
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        configuration.preferredSymbolConfigurationForImage = symbolConfig
        
        let button = UIButton(configuration: configuration)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var mapButton: UIButton = {
        var configuration = UIButton.Configuration.glass()
        
        configuration.image = UIImage(systemName: "location.fill")
        configuration.imagePlacement = .all
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        configuration.preferredSymbolConfigurationForImage = symbolConfig
        
        let button = UIButton(configuration: configuration)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    var onMapButtonTapped: (() -> Void)?
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [listButton, mapButton])
        
        stackView.axis = .vertical
        
        stackView.spacing = 16
        
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
    
    @objc func mapButtonTapped() {
        if let coordinate = mapView.myLocation?.coordinate {
            moveCameraToUser(coordinate)
        } else {
            onMapButtonTapped?()
        }
    }
    
    func setupLayout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mapView)
        addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsStackView.widthAnchor.constraint(equalToConstant: 70),
            listButton.heightAnchor.constraint(equalToConstant: 70),
            mapButton.heightAnchor.constraint(equalToConstant: 70)
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
    }
}

