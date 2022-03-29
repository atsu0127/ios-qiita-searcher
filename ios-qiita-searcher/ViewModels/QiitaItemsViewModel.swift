//
//  QiitaItemsViewModel.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/20.
//

import Foundation
import Combine

final class QiitaItemsViewModel: ObservableObject {
  // MARK: - Variables
  @Published var items: [QiitaItem] = []
  @Published var searchWord = ""
  @Published var sortTarget: QiitaItem.SortTargets = .title
  @Published var isLoading = false
  @Published var isEmpty = false
  private var itemsOperator: QiitaItemsOperator = .init()
  private var cancellables: Set<AnyCancellable> = []
  
  // MARK: - Initializer
  init() {
    self.bind()
  }
  
  // MARK: - Deinitializer
  deinit {
    self.cancellables.forEach { $0.cancel() }
  }
  
  // MARK: - Bind
  func bind() {
    self.$sortTarget
      .sink { [weak self] target in
        guard let self = self else { return }
        self.items = self.sortItem(items: self.items, by: target)
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Actions
  @MainActor
  func submit() {
    Task { [weak self] in
      guard let self = self else { return }
      self.isLoading = true
      self.items = await self.loadData(by: self.searchWord, sort: self.sortTarget)
      self.isLoading = false
      self.isEmpty = self.items.count == 0
    }
  }
  
  func loadData(by word: String, sort target: QiitaItem.SortTargets) async -> [QiitaItem] {
    do {
      let gotItems = try await itemsOperator.search(by: word)
      return itemsOperator.sort(items: gotItems, by: target)
    } catch {
      print(error.localizedDescription)
      return []
    }
  }
  
  func sortItem(items: [QiitaItem], by target: QiitaItem.SortTargets) -> [QiitaItem] {
    return itemsOperator.sort(items: items, by: target)
  }
}
