//
//  Action.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/04/08.
//

import Foundation

enum Action {
  case addItems([QiitaItem])
  case sortItems(QiitaItem.SortTargets)
  case clearItems
  case selectItem(QiitaItem?)
  case startLoad
  case stopLoad
}
