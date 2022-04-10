//
//  QiitaItem.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/19.
//

import Foundation

struct QiitaItem: Codable, Identifiable, Hashable {
  let id = UUID()
  let title: String
  let body: String
  let createdAt: Date
  let updatedAt: Date
  let likesCount: Int
  let pageViewsCount: Int?
  let commentsCount: Int
  let url: String
  static let mock: QiitaItem = .init(
    title: "Test Title",
    body: "TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTest\nBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBodyBody",
    createdAt: Date(),
    updatedAt: Date(),
    likesCount: 10,
    pageViewsCount: 10,
    commentsCount: 10,
    url: "https://www.yahoo.co.jp/"
  )
  
  enum CodingKeys: String, CodingKey {
    case title = "title"
    case body = "body"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case likesCount = "likes_count"
    case pageViewsCount = "page_views_count"
    case commentsCount = "comments_count"
    case url = "url"
  }
  
  enum SortTargets: String, CaseIterable, Identifiable {
    case title = "タイトル順"
    case createdAt = "作成日順"
    case likesCount = "いいね数順"
    var id: String {
      rawValue
    }
  }
}

extension QiitaItem.SortTargets {
  func toKeyPath() -> KeyPath<QiitaItem, AnyComparable> {
    switch self {
      case .title:
        return \.title.anyComparable
      case .createdAt:
        return \.createdAt.anyComparable
      case .likesCount:
        return \.likesCount.anyComparable
    }
  }
}
