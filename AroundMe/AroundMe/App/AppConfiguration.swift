//
//  AppConfiguration.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 16.02.2026.
//

import Foundation
import GoogleMaps
import GooglePlaces

enum AppConfiguration {
    
    static func configureGoogleServices() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            fatalError("Error: Secrets.plist file not found in Bundle.")
        }
        
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("Error: Failed to read the contents of Secrets.plist.")
        }
        
        guard let apiKey = dict["GoogleMapsAPIKey"] as? String, !apiKey.isEmpty else {
            fatalError("Error: The key 'GoogleMapsAPIKey' is missing or empty in Secrets.plist.")
        }
        
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
    }
    
}
