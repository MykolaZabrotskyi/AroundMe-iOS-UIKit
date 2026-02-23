//
//  ListView.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 20.02.2026.
//

import UIKit

final class ListView: UIView {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    
    func setupTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
    }
}

// MARK: - Private Methods

private extension ListView {
    // MARK: - Setup / Configuration
    
    func setupLayout() {
        backgroundColor = .systemBackground
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Constants

private extension ListView {
    enum Constant {
        static let rowHeight: CGFloat = 100.0
    }
}
