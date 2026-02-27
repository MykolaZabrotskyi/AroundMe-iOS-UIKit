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
        
        let presenterDependencies = MapPresenter.Dependencies(router: router, placesService: placesService)
        let presenter = MapPresenter(dependencies: presenterDependencies)
        
        let viewControllerDependencies = MapViewController.Dependencies(presenter: presenter)
        let viewController = MapViewController(dependencies: viewControllerDependencies)
        
        presenter.view = viewController
        router.viewController = viewController
        
        return viewController
    }
}
