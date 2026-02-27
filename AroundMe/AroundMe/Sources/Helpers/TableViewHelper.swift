//
//  TableViewHelper.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 23.02.2026.
//

import UIKit

public protocol SelfIdentifiable { }

public extension SelfIdentifiable {
    static var identifier: String {
        String(describing: self)
    }
}

extension UITableViewCell: SelfIdentifiable { }

extension UICollectionReusableView: SelfIdentifiable { }

extension UITableViewHeaderFooterView: SelfIdentifiable { }

public extension UICollectionView {
    func register<Cell: UICollectionViewCell>(cell: Cell.Type) {
        self.register(cell.self, forCellWithReuseIdentifier: cell.identifier)
    }
  
    func register<T: UICollectionReusableView>(
        view: T.Type,
        for kind: String,
        with identifier: String = T.identifier
    ) {
        self.register(
            view.self,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: identifier
        )
    }
    
    func dequeue<Cell: UICollectionViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(
            withReuseIdentifier: Cell.identifier,
            for: indexPath
        ) as? Cell else {
            fatalError("Cell \(String(describing: Cell.self)) not registered")
        }
        return cell
    }
    
    func dequeueSupplementary<View: UICollectionReusableView>(of kind: String, for indexPath: IndexPath) -> View {
        guard let view = self.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: View.identifier,
            for: indexPath
        ) as? View else {
            fatalError("View \(String(describing: View.self)) not registered")
        }
        return view
    }
}

public extension UITableView {
    func register<Cell: UITableViewCell>(cell: Cell.Type) {
        self.register(cell.self, forCellReuseIdentifier: cell.identifier)
    }
    
    func register<HeaderFooter: UITableViewHeaderFooterView>(headerFooterView: HeaderFooter.Type) {
        self.register(headerFooterView.self, forHeaderFooterViewReuseIdentifier: headerFooterView.identifier)
    }
    
    func dequeue<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell else {
            fatalError("Cell \(String(describing: Cell.self)) not registered")
        }
        return cell
    }
    
    func dequeueHeaderFooter<HeaderFooter: UITableViewHeaderFooterView>() -> HeaderFooter {
        guard let headerFooter = self.dequeueReusableHeaderFooterView(
            withIdentifier: HeaderFooter.identifier
        ) as? HeaderFooter else {
            fatalError("HeaderFooter \(String(describing: HeaderFooter.self)) not registered")
        }
        return headerFooter
    }
}
