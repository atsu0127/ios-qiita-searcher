//
//  QiitaItemsPresenter.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/26.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Presenter Input
protocol QiitaItemsPresenterInput: AnyObject {
  func search(in word: String, orderBy target: QiitaItem.SortTargets) async
  func sort(orderBy target: QiitaItem.SortTargets)
//  func selectItem(_ item: QiitaItem)
}

// MARK: - Presenter Output
protocol QiitaItemsPresenterOutput {
//  func moveToDetail(of item: QiitaItem)
  func updateItems(by items: [QiitaItem])
//  func selectItem(_ item: QiitaItem)
  func showError(msg: String)
  func hideError()
  func startSearch()
  func endSearch()
}
// MARK: - Presenter
class QiitaItemsPresenter: UIViewController {
  private var contentView: ContentView!
  private var hostingController: UIHostingController<ContentView>!
  private var model: QiitaItemsModel!
  private var items: [QiitaItem] = []
  
  public func inject(view: ContentView, model: QiitaItemsModel) {
    self.contentView = view
    self.model = model
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let _ = model, let contentView = contentView else {
      print("Model, Viewがnilです")
      return
    }
    
    hostingController = UIHostingController(rootView: contentView)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    hostingController.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height).isActive = true
    hostingController.view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
    view.addSubview(hostingController.view)
  }
}

extension QiitaItemsPresenter: QiitaItemsPresenterInput {
  // MARK: - Input Functions
  func search(in word: String, orderBy target: QiitaItem.SortTargets) async {
    guard let contentView = contentView, let model = model else { return }
    contentView.startSearch()
    contentView.hideError()
    defer {
      contentView.endSearch()
    }
    do {
      // 検索して
      let loadedItems = try await model.search(by: word)
      
      // ソートして
      let sortedItems = model.sort(loadedItems, by: target)
      
      // セットして、view呼び出す
      self.items = sortedItems
      contentView.updateItems(by: sortedItems)
    } catch {
      // エラーだったら表示する
      contentView.showError(msg: error.localizedDescription)
    }
  }
  
  func sort(orderBy target: QiitaItem.SortTargets) {
    guard let contentView = contentView, let model = model else { return }
    
    // ソートする
    let sortedItems = model.sort(self.items, by: target)
    
    // セットして、反映する
    self.items = sortedItems
    contentView.updateItems(by: sortedItems)
  }
  
//  func selectItem(_ item: QiitaItem) {
//    // viewにセットするだけ(無駄)
//    self.view.selectItem(item)
//  }
}
