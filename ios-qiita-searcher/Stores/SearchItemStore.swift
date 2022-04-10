//
//  SearchItemStore.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/04/08.
//

import Foundation

final class SearchItemStore: Store {
  static let shared = SearchItemStore(dispatcher: .shared)
  @Published var items = [QiitaItem]()
  @Published var selectedItem: QiitaItem?
  @Published var isEmpty = false
  @Published var isLoading = false
  
  override func onDispatch(_ action: Action) {
    switch action {
      case .addItems(let items):
        DispatchQueue.main.async {
          if items.isEmpty {
            self.isEmpty = true
            return
          }
          self.isEmpty = false
          self.items.append(contentsOf: items)
        }
      case .clearItems:
        DispatchQueue.main.async {
          self.items.removeAll()
        }
      case .sortItems(let target):
        DispatchQueue.main.async {
          self.items = self.items.sorted(by: target.toKeyPath(), using: <)
        }
      case .startLoad:
        DispatchQueue.main.async {
          self.isLoading = true
        }
      case .stopLoad:
        DispatchQueue.main.async {
          self.isLoading = false
        }
      case .selectItem(let item):
        DispatchQueue.main.async {
          self.selectedItem = item
        }
    }
  }
}
