//
//  SceneDelegate.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/27.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let presenter = QiitaItemsPresenter()
    let view = ContentView(presenter: presenter)
    let model = QiitaItemsModel()
    presenter.inject(view: view, model: model)
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = presenter
    window?.makeKeyAndVisible()
  }
}
