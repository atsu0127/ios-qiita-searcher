//
//  QiitaItemsController.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/20.
//

import Foundation

final class QiitaItemsController {
  // MARK: - Variables
  var model: QiitaItemsModel
  
  // MARK: - Init
  required init(model: QiitaItemsModel) {
    self.model = model
  }
  
  // MARK: - Actions
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
