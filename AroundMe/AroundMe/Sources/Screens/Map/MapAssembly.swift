//
//  MapAssembly.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 27.02.2026.
//

import UIKit

final class MapAssembly {
    static func build() -> UIViewController {
        let router = MapRouter()
        let placesService = PlacesService()
        let viewController = MapViewController()
        let presenter = MapPresenter(router: router, placesService: placesService, viewController: viewController)
        
        router.inject(viewController: viewController)
        viewController.inject(presenter: presenter)
        
        return viewController
    }
}
