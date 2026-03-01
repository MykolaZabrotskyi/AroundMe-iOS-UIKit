//
//  MapRouter.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 27.02.2026.
//

import UIKit
import CoreLocation

protocol MapRouterProtocol: AnyObject {
    func pushToList(with places: [PlaceModel])
    func popToMap(coordinate: CLLocationCoordinate2D)
}

final class MapRouter {
    
    // MARK: - Properties
    
    private weak var viewController: UIViewController?
    
    // MARK: - Internal Methods
    
    func inject(viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - MapRouterProtocol

extension MapRouter: MapRouterProtocol {
    func pushToList(with places: [PlaceModel]) {
        let listViewController = ListAssembly.build(places: places) { [weak self] coordinate in
            self?.popToMap(coordinate: coordinate)
        }
        
        viewController?.navigationController?.pushViewController(listViewController, animated: true)
    }
    
    func popToMap(coordinate: CLLocationCoordinate2D) {
        guard let mapViewController = viewController as? MapViewControllerProtocol else {
            return
        }
        
        mapViewController.moveCameraToPlace(coordinate)
        mapViewController.openMarkerSnippet(at: coordinate)
        
        viewController?.navigationController?.popViewController(animated: true)
    }
}
