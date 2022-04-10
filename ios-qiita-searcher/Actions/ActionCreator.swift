//
//  ActionCreator.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/04/08.
//

import Foundation

final class ActionCreator {
  private let qiitaRepository: QiitaRepository
  private let dispatcher: Dispatcher
  
  init(dispatcher: Dispatcher = .shared,
       qiitaRepository: QiitaRepository = .init()) {
    self.qiitaRepository = qiitaRepository
    self.dispatcher = dispatcher
  }
  
  func searchItems(by word: String, orderBy target: QiitaItem.SortTargets) async {
    // 検索前に既存のものを消す
    dispatcher.dispatch(.clearItems)
    
    do {
      let items = try await qiitaRepository.search(by: word)
      dispatcher.dispatch(.addItems(items))
      dispatcher.dispatch(.sortItems(target))
    } catch {
      print(error)
    }
  }
  
  func clearItems() {
    dispatcher.dispatch(.clearItems)
  }
  
  func sortItems(by target: QiitaItem.SortTargets) {
    dispatcher.dispatch(.sortItems(target))
  }
  
  func startLoad() {
    dispatcher.dispatch(.startLoad)
  }
  
  func stopLoad() {
    dispatcher.dispatch(.stopLoad)
  }
  
  func selectItem(_ item: QiitaItem?) {
    dispatcher.dispatch(.selectItem(item))
  }
}
