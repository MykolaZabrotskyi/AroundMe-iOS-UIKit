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
        let properties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.addressComponents].map { $0.rawValue }
        let request = GMSPlaceSearchNearbyRequest(locationRestriction: circularRestriction, placeProperties: properties)
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
            
            let places = results.map { gmsPlace in
                PlaceModel(
                    name: gmsPlace.name ?? "",
                    coordinate: gmsPlace.coordinate,
                    fullAddress: PlacesService.formatAddress(gmsPlace.addressComponents)
                )
            }
            
            DispatchQueue.main.async {
                completion(.success(places))
            }
        }
    }
}

private extension PlacesService {
    
    static func formatAddress(_ components: [GMSAddressComponent]?) -> String {
        
        guard let components = components else {
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
        static let includedPlaceTypes = ["restaurant", "cafe"]
        
        enum ErrorConstants {
            static let domain = "AroundMe"
            static let code = -1
            static let descriptionKey = "Unknown error"
        }
    }
    
}
