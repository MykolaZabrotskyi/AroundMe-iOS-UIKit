//
//  MapAssembly.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 27.02.2026.
//

import UIKit

final class MapAssembly {
    static func build() -> UIViewController {
        let placesService = PlacesService()
        
        let viewController = MapViewController()
        let router = MapRouter(viewController: viewController)
        let presenter = MapPresenter(router: router, placesService: placesService, viewController: viewController)
        
        viewController.inject(presenter: presenter)
        
        return viewController
    }
}
