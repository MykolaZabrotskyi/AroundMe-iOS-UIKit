//
//  PlaceService.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 18.02.2026.
//

import CoreLocation
import GooglePlaces

class PlacesService {
    func searchNearby(at location: CLLocationCoordinate2D, completion: @escaping ([PlaceModel]) -> Void) {
        let circularRestriction = GMSPlaceCircularLocationOption(location, 5000.0)
        let properties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.addressComponents].map { $0.rawValue }
        let request = GMSPlaceSearchNearbyRequest(locationRestriction: circularRestriction, placeProperties: properties)
        request.includedTypes = ["restaurant", "cafe"]
        
        GMSPlacesClient.shared().searchNearby(with: request) { results, error in
            guard let results = results, error == nil else { return }
            
            let places = results.map { gmsPlace in
                PlaceModel(
                    name: gmsPlace.name ?? "",
                    coordinate: gmsPlace.coordinate,
                    fullAddress: PlacesService.formatAddress(gmsPlace.addressComponents)
                )
            }
            completion(places)
        }
    }
    
    private static func formatAddress(_ components: [GMSAddressComponent]?) -> String {
        guard let components = components else { return "" }
        let country = components.first(where: { $0.types.contains("country") })?.name ?? ""
        let city = components.first(where: { $0.types.contains("locality") })?.name ?? ""
        let route = components.first(where: { $0.types.contains("route") })?.name ?? ""
        let streetNumber = components.first(where: { $0.types.contains("street_number") })?.name ?? ""
        return "\(country) \(city)\n\(route) \(streetNumber)".trimmingCharacters(in: .whitespaces)
    }
}

//private func nearbySearch(_ location: CLLocationCoordinate2D, radius: Double = 5000.0) {
//    var placeResults: [GMSPlace] = []
//    
//    let circularLocationRestriction = GMSPlaceCircularLocationOption(location, radius)
//    
//    let placeProperties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate, GMSPlaceProperty.addressComponents].map {$0.rawValue}
//    
//    let request = GMSPlaceSearchNearbyRequest(locationRestriction: circularLocationRestriction, placeProperties: placeProperties)
//    let includedTypes = ["restaurant", "cafe"]
//    request.includedTypes = includedTypes
//    
//    let callback: GMSPlaceSearchNearbyResultCallback = { [weak self] results, error in
//        guard let self, error == nil else {
//            if let error {
//                print(error.localizedDescription)
//            }
//            return
//        }
//        guard let results = results else {
//            return
//        }
//        placeResults = results
//        self.displayPlacesOnMap(placeResults)
//    }
//    
//    GMSPlacesClient.shared().searchNearby(with: request, callback: callback)
//    
//}
