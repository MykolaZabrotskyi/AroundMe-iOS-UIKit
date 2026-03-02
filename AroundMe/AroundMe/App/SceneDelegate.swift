//
//  SceneDelegate.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 16.02.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        let window = UIWindow(windowScene: windowScene)
        let mapViewController = MapAssembly.build()
        let navigationController = UINavigationController(rootViewController: mapViewController)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}

