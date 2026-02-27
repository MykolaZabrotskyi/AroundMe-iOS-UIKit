//
//  ListAssembly.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 27.02.2026.
//

import UIKit
import CoreLocation

final class ListAssembly {
    static func build(places: [PlaceModel],onPlaceSelected: @escaping (CLLocationCoordinate2D) -> Void) -> UIViewController {
        let router = ListRouter(onPlaceSelected: onPlaceSelected)
        
        let presenterDependencies = ListPresenter.Dependencies(router: router, places: places)
        let presenter = ListPresenter(dependencies: presenterDependencies)
        
        let viewControllerDependencies = ListViewController.Dependencies(presenter: presenter)
        let viewController = ListViewController(dependencies: viewControllerDependencies)
        
        presenter.view = viewController
        router.viewController = viewController
        
        return viewController
    }
}
