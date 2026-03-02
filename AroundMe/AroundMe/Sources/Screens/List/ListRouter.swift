//
//  ListRouter.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 27.02.2026.
//

import UIKit
import CoreLocation

protocol ListRouterProtocol: AnyObject {
    func popToMap(with coordinate: CLLocationCoordinate2D)
}

final class ListRouter {
    
    // MARK: - Properties
    
    private weak var viewController: UIViewController?
    
    private let onPlaceSelected: (CLLocationCoordinate2D) -> Void
    
    // MARK: - Init
    
    init(viewController: UIViewController, onPlaceSelected: @escaping (CLLocationCoordinate2D) -> Void) {
        self.viewController = viewController
        self.onPlaceSelected = onPlaceSelected
    }
}

// MARK: - ListRouterProtocol

extension ListRouter: ListRouterProtocol {
    func popToMap(with coordinate: CLLocationCoordinate2D) {
        onPlaceSelected(coordinate)
    }
}
