//
//  ListViewController.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 19.02.2026.
//

import UIKit
import CoreLocation

final class ListViewController: UIViewController {
    
    private let mainView = ListView()
    private let places: [PlaceModel]
    
    init(places: [PlaceModel]) {
        self.places = places
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.title
        
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
    }
    
    var onPlaceSelected: ((CLLocationCoordinate2D) -> Void)?
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlaceTableViewCell.identifier,
            for: indexPath
        ) as? PlaceTableViewCell else {
            return UITableViewCell()
        }
        
        let place = places[indexPath.row]
        cell.configure(with: place)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPlace = places[indexPath.row]
        onPlaceSelected?(selectedPlace.coordinate)
    }
}

private extension ListViewController {
    
    enum Constants {
        static let title: String = "List"
    }
}
