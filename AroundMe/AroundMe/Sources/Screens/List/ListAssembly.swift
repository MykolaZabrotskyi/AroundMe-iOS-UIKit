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
        let viewController = ListViewController()
        let presenter = ListPresenter(router: router, places: places, viewController: viewController)
        
        router.inject(viewController: viewController)
        viewController.inject(presenter: presenter)
        
        return viewController
    }
}
