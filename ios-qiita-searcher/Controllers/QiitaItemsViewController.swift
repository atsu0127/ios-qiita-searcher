//
//  QiitaItemsViewController.swift
//  ios-qiita-searcher
//
//  Created by 田畑篤智 on 2022/03/22.
//

import Foundation
import UIKit
import SwiftUI


protocol QiitaItemsViewProtocol: AnyObject {
  func loadData(by word: String, sort target: QiitaItem.SortTargets) async
  func sortItem(by target: QiitaItem.SortTargets) async
}

class QiitaItemsViewController: UIViewController {
  private let model = QiitaItemsModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let newViewController = UIHostingController(rootView: ContentView(delegate: self, model: self.model))
    newViewController.view.translatesAutoresizingMaskIntoConstraints = false
    newViewController.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
    newViewController.view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
    
    view.addSubview(newViewController.view)
  }
}

extension QiitaItemsViewController: QiitaItemsViewProtocol {
  func loadData(by word: String, sort target: QiitaItem.SortTargets) async {
    if word == "" {
      return
    }
    await model.search(by: word)
    await model.sort(by: target)
  }
  
  func sortItem(by target: QiitaItem.SortTargets) async {
    await model.sort(by: target)
  }
}
