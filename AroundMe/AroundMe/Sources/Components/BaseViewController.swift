//
//  BaseViewController.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 02.03.2026.
//

import UIKit

class BaseViewController<PresenterType>: UIViewController {
    
    // MARK: - Properties
    
    private(set) var presenter: PresenterType!
    
    // MARK: - Lyfecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: - Internal Methods
    
    func inject(presenter: PresenterType) {
        self.presenter = presenter
    }
}


private extension BaseViewController {
    
    // MARK: - Setup/Configuration
    
    func setupLayout() {
        view.backgroundColor = .systemBackground
    }
}
