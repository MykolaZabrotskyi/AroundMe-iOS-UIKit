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
    
    init(onPlaceSelected: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onPlaceSelected = onPlaceSelected
    }
    
    // MARK: - Internal Methods
    
    func inject(viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - ListRouterProtocol

extension ListRouter: ListRouterProtocol {
    func popToMap(with coordinate: CLLocationCoordinate2D) {
        onPlaceSelected(coordinate)
    }
}
