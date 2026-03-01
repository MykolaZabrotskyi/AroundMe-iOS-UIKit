//
//  ListViewController.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 19.02.2026.
//

import UIKit
import CoreLocation

protocol ListViewControllerProtocol: AnyObject {
    
}

final class ListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var presenter: ListPresenterProtocol!
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = Constant.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(cell: PlaceTableViewCell.self)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constant.title
        
        setupLayout()
        setupTableView()
    }
    
    // MARK: - Internal Methods
    
    func inject(presenter: ListPresenterProtocol) {
        self.presenter = presenter
    }
}

// MARK: - Private Methods

private extension ListViewController {
    
    // MARK: - Setup / Configuration
    
    func setupLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - ListViewControllerProtocol

extension ListViewController: ListViewControllerProtocol {
    
}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlaceTableViewCell = tableView.dequeue(for: indexPath)
        
        cell.configure(with: presenter.place(at: indexPath.row))
        
        return cell
    }
}

// MARK: - UITableVIewDelegate

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        presenter.didSelectRow(at: indexPath.row)
    }
}

// MARK: - Constants

private extension ListViewController {
    enum Constant {
        static let title = "List"
        static let rowHeight: CGFloat = 100.0
    }
}
