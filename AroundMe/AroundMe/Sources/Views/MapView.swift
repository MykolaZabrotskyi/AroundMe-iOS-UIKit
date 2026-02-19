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
    
    private(set) var mapView: GMSMapView = {
        let options = GMSMapViewOptions()
        options.backgroundColor = .systemBackground
        
        let map = GMSMapView(options: options)
        map.mapType = .normal
        map.isIndoorEnabled = false
        map.isTrafficEnabled = false
        map.isTransitEnabled = false
        map.isBuildingsEnabled = false
        
        map.settings.myLocationButton = true
        map.settings.rotateGestures = false
        map.settings.tiltGestures = false
        map.settings.consumesGesturesInView = true
        
        map.accessibilityElementsHidden = false
        
        return map
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayout()
        setupMapConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupMapConfiguration() {
        applyMapStyle()
        
        mapView.padding = Constants.mapInsets
    }
    
    private func applyMapStyle() {
        
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
    
    enum Constants {
        static let zoomCameraOnUser: Float = 13.0
        
        static let mapInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )

    }
}

