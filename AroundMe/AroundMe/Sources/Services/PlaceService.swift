//
//  PlaceService.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 18.02.2026.
//

import CoreLocation
import GooglePlaces

final class PlacesService {
    // MARK: - Internal Methods
    
    func searchNearby(at location: CLLocationCoordinate2D, completion: @escaping (Result<[PlaceModel], Error>) -> Void) {
        let circularRestriction = GMSPlaceCircularLocationOption(location, Constant.searchRadius)
        let properties = [
            GMSPlaceProperty.name,
            GMSPlaceProperty.coordinate,
            GMSPlaceProperty.addressComponents,
            GMSPlaceProperty.iconImageURL,
            GMSPlaceProperty.rating
        ].map { $0.rawValue }
        
        let request = GMSPlaceSearchNearbyRequest(
            locationRestriction: circularRestriction,
            placeProperties: properties
        )
        request.includedTypes = Constant.includedPlaceTypes
        
        GMSPlacesClient.shared().searchNearby(with: request) { results, error in
            guard let results, error == nil else {
                let errorToReturn = error ??
                NSError(
                    domain: Constant.ErrorConstant.domain,
                    code: Constant.ErrorConstant.code,
                    userInfo: [NSLocalizedDescriptionKey: Constant.ErrorConstant.descriptionKey]
                )
                
                DispatchQueue.main.async {
                    completion(.failure(errorToReturn))
                }
                
                return
            }
            
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let places: [PlaceModel] = results.map { gmsPlace in
                let placeLocation = CLLocation(
                    latitude: gmsPlace.coordinate.latitude,
                    longitude: gmsPlace.coordinate.longitude
                )
                
                let formattedRating: String
                if gmsPlace.rating > 0 {
                    formattedRating = "★ " + String(format: "%.1f", gmsPlace.rating)
                } else {
                    formattedRating = Constant.EmptyText.rating
                }
                
                let distanceToPlace = userLocation.distance(from: placeLocation)
                
                let formattedDistance: String
                if distanceToPlace < 1000 {
                    formattedDistance = String(Int(distanceToPlace)) + " m"
                } else {
                    let kilometers = distanceToPlace / 1000.0
                    formattedDistance = String(format: "%.1f", kilometers) + " km"
                }
                
                return PlaceModel(
                    name: gmsPlace.name ?? Constant.EmptyText.name,
                    coordinate: gmsPlace.coordinate,
                    fullAddress: PlacesService.formatAddress(gmsPlace.addressComponents),
                    iconURL: gmsPlace.iconImageURL,
                    rating: formattedRating,
                    distance: formattedDistance
                )
            }
            
            let sortedPlaces: [PlaceModel] = places.sorted(by: { firstPlace, secondPlace in
                guard let firstDistance = Int(firstPlace.distance ?? "") else {
                    return false
                }
                
                guard let secondDistance = Int(secondPlace.distance ?? "") else {
                    return false
                }
                
                return firstDistance < secondDistance
            })
            
            DispatchQueue.main.async {
                completion(.success(sortedPlaces))
            }
        }
    }
}

// MARK: - Private Methods

private extension PlacesService {
    static func formatAddress(_ components: [GMSAddressComponent]?) -> String {
        guard let components else {
            return Constant.EmptyText.adress
        }
        
        let country = components.first(where: { $0.types.contains("country") })?.name ?? ""
        let city = components.first(where: { $0.types.contains("locality") })?.name ?? ""
        let route = components.first(where: { $0.types.contains("route") })?.name ?? ""
        let streetNumber = components.first(where: { $0.types.contains("street_number") })?.name ?? ""
        
        return "\(country) \(city)\n\(route) \(streetNumber)".trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Constants

private extension PlacesService {
    enum Constant {
        static let searchRadius: Double = 5000.0
        static let includedPlaceTypes = ["restaurant", "cafe"]
        
        enum ErrorConstant {
            static let domain = "AroundMe"
            static let code = -1
            static let descriptionKey = "Unknown error"
        }
        
        enum EmptyText {
            static let adress = "Address not available"
            static let rating = "Rating not available"
            static let distance = "Distance not available"
            static let name = "Name not available"
        }
    }
}
