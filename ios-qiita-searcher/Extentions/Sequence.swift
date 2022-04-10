//
//  QiitaItem+Sequence.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/04/09.
//

import Foundation

extension Sequence {
  func sorted<T: Comparable>(
    by keyPath: KeyPath<Element, T>,
    using comparator: (T, T) -> Bool = (<)
  ) -> [Element] {
    sorted { a, b in
      comparator(a[keyPath: keyPath], b[keyPath: keyPath])
    }
  }
}
