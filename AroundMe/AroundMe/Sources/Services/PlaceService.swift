//
//  PlaceService.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 18.02.2026.
//

import CoreLocation
import GooglePlaces

final class PlacesService {
    
    func searchNearby(at location: CLLocationCoordinate2D, completion: @escaping (Result<[PlaceModel], Error>) -> Void) {
        let circularRestriction = GMSPlaceCircularLocationOption(location, Constants.searchRadius)
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
        request.includedTypes = Constants.includedPlaceTypes
        
        GMSPlacesClient.shared().searchNearby(with: request) { results, error in
            guard let results, error == nil else {
                let errorToReturn = error ??
                NSError(
                    domain: Constants.ErrorConstants.domain,
                    code: Constants.ErrorConstants.code,
                    userInfo: [NSLocalizedDescriptionKey: Constants.ErrorConstants.descriptionKey]
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
                
                let distanceToPlace = userLocation.distance(from: placeLocation)
                
                return PlaceModel(
                    name: gmsPlace.name ?? "",
                    coordinate: gmsPlace.coordinate,
                    fullAddress: PlacesService.formatAddress(gmsPlace.addressComponents),
                    iconURL: gmsPlace.iconImageURL,
                    rating: gmsPlace.rating > 0 ? gmsPlace.rating : nil,
                    distance: distanceToPlace
                )
            }
            
            let sortedPlaces: [PlaceModel] = places.sorted(by: { firstPlace, secondPlace in
                let firstDistance = firstPlace.distance ?? 0
                let secondDistance = secondPlace.distance ?? 0
                
                return firstDistance < secondDistance
            })
            
            DispatchQueue.main.async {
                completion(.success(sortedPlaces))
            }
        }
    }
}

private extension PlacesService {
    
    static func formatAddress(_ components: [GMSAddressComponent]?) -> String {
        guard let components else {
            return ""
        }
        
        let country = components.first(where: { $0.types.contains("country") })?.name ?? ""
        let city = components.first(where: { $0.types.contains("locality") })?.name ?? ""
        let route = components.first(where: { $0.types.contains("route") })?.name ?? ""
        let streetNumber = components.first(where: { $0.types.contains("street_number") })?.name ?? ""
        
        return "\(country) \(city)\n\(route) \(streetNumber)".trimmingCharacters(in: .whitespaces)
    }
}

private extension PlacesService {
    
    enum Constants {
        static let searchRadius: Double = 5000.0
        static let includedPlaceTypes: [String] = ["restaurant", "cafe"]
        
        enum ErrorConstants {
            static let domain: String = "AroundMe"
            static let code: Int = -1
            static let descriptionKey: String = "Unknown error"
        }
    }
}
