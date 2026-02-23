//
//  PlaceModel.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 18.02.2026.
//

import CoreLocation

struct PlaceModel {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let fullAddress: String
    let iconURL: URL?
    let rating: String?
    let distance: String?
}
