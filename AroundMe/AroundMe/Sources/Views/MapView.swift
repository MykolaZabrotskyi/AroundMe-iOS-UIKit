//
//  MapView.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 17.02.2026.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapView: UIView {
    
    private(set) var mapView: GMSMapView
    
    override init(frame: CGRect) {
        let options = GMSMapViewOptions()
        options.backgroundColor = .systemBackground
        
        mapView = GMSMapView(options: options)
        super.init(frame: frame)
        
        setupLayout()
        applyStylingToMap()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
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
    
    private func applyStylingToMap() {
        mapView.mapType = .normal
        
        let mapStyleJson = """
        [
          {
            "featureType": "poi",
            "stylers": [
              { "visibility": "off" }
            ]
          }
        ]
        """
        
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: mapStyleJson)
        } catch {
            fatalError("Error: \(error)")
        }
        
        mapView.isIndoorEnabled = false
        mapView.isTrafficEnabled = false
        mapView.isTransitEnabled = false
        mapView.isBuildingsEnabled = false
        
        mapView.accessibilityElementsHidden = false
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        mapView.overrideUserInterfaceStyle = .unspecified
        
        mapView.settings.myLocationButton = true
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.consumesGesturesInView = true
    }
    
    func updateMyLocationEnabled(_ enabled: Bool) {
        mapView.isMyLocationEnabled = enabled
    }
    
    func moveCameraToUser(_ location: CLLocationCoordinate2D, zoom: Float = 13.0) {
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: zoom)
        mapView.animate(to: camera)
    }
    
    func renderMarkers(for places: [PlaceModel]) {
        // mapView.clear()
        for place in places {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            marker.snippet = place.fullAddress
            marker.appearAnimation = .pop
            marker.map = mapView
        }
    }
}
