//
//  ListPresenter.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 27.02.2026.
//

import Foundation
import CoreLocation

protocol ListPresenterProtocol: AnyObject {
    var numberOfRows: Int { get }
    func place(at index: Int) -> PlaceModel
    func didSelectRow(at index: Int)
}

final class ListPresenter {
    
    // MARK: - Properties
    
    weak var view: ListViewControllerProtocol?
    
    private let router: ListRouterProtocol
    private var places: [PlaceModel]
    
    struct Dependencies {
        let router: ListRouterProtocol
        let places: [PlaceModel]
    }
    
    // MARK: - Init
    
    init(dependencies: Dependencies) {
        self.router = dependencies.router
        self.places = dependencies.places
    }
}

// MARK: - ListPresenterProtocol

extension ListPresenter: ListPresenterProtocol {
    var numberOfRows: Int {
        return places.count
    }
    
    func place(at index: Int) -> PlaceModel {
        return places[index]
    }
    
    func didSelectRow(at index: Int) {
        let selectedCoordinate = places[index].coordinate
        router.popToMap(with: selectedCoordinate)
    }
}
