//
//  PlaceModel.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 18.02.2026.
//

import CoreLocation
import GooglePlaces

struct PlaceModel {
    
    // MARK: - Properties
    
    let name: String
    let coordinate: CLLocationCoordinate2D
    let fullAddress: String
    let iconURL: URL?
    let rating: Float?
    let distance: CLLocationDistance?
    
    var formattedRating: String {
        guard let rating else {
            return ""
        }
        
        let formattedRating = rating > 0
        ? "★ " + String(format: "%.1f", rating)
        : Constant.EmptyText.rating
        
        return formattedRating
    }
    
    var formattedDistance: String {
        guard let distance = distance else {
            return ""
        }
        
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        return Self.distanceFormatter.string(from: measurement)
    }
}

// MARK: - Private Methods

private extension PlaceModel {
    static let distanceFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        return formatter
    }()
}

// MARK: - Constants

private extension PlaceModel {
    enum Constant {
        enum EmptyText {
            static let adress = "Address not available"
            static let rating = "Rating not available"
            static let distance = "Distance not available"
            static let name = "Name not available"
        }
    }
}
