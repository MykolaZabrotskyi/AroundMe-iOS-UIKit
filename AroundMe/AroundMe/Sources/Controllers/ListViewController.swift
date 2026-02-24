//
//  ListViewController.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 19.02.2026.
//

import UIKit
import CoreLocation

final class ListViewController: UIViewController {
    
    // MARK: - Properties
    
    var onPlaceSelected: ((CLLocationCoordinate2D) -> Void)?
    
    private let mainView = ListView()
    private let places: [PlaceModel]
    
    // MARK: - Init
    
    init(places: [PlaceModel]) {
        self.places = places
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constant.title
        
        mainView.setupTableView(delegate: self, dataSource: self)
    }
}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlaceTableViewCell = tableView.dequeue(for: indexPath)
        
        let place = places[indexPath.row]
        cell.configure(with: place)
        
        return cell
    }
}

// MARK: - UITableVIewDelegate

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPlace = places[indexPath.row]
        onPlaceSelected?(selectedPlace.coordinate)
    }
}

// MARK: - Constants

private extension ListViewController {
    enum Constant {
        static let title = "List"
    }
}
