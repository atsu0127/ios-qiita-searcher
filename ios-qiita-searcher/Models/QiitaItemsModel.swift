//
//  QiitaItemsModel.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/19.
//

import Foundation

// MARK: - Modelクラス
final class QiitaItemsModel: ObservableObject {
  // MARK: - Outputs
  @Published var items: [QiitaItem] = []
  @Published var error: Error?
  @Published var isLoading = false
  @Published var isEmpty = false
  
  // MARK: - Varuables
  private var baseURL: URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "qiita.com"
    return components
  }
  
  // MARK: - Callable Functions
  func sort(by target: QiitaItem.SortTargets) async {
    switch target {
      case .title:
        items.sort { item1, item2 in
          item1.title < item2.title
        }
      case .createdAt:
        items.sort { item1, item2 in
          item1.createdAt < item2.createdAt
        }
      case .likesCount:
        items.sort { item1, item2 in
          item1.likesCount < item2.likesCount
        }
    }
  }
  
  func search(by word: String) async {
    self.error = nil
    let (url, error) = urlBuilder(by: word)
    if let error = error {
      self.error = error
      print("url作成でエラー: \(error.localizedDescription)")
      return
    }
    
    guard let url = url else {
      print("urlが取得できませんでした")
      return
    }
    
    self.isLoading = true
    do {
      let data = try await fetch(to: url)
      if data.count == 0 {
        self.isEmpty = true
      }
      self.items = data
      self.isLoading = false
    } catch {
      self.error = error
      print("データ取得でエラー: \(error.localizedDescription)")
      print(error)
      self.isLoading = false
      return
    }
  }
  
  // MARK: - Support Functions
  @MainActor
  private func fetch(to url: URL) async throws -> [QiitaItem] {
    do {
      var request = URLRequest(url: url)
      let token = loadToken()
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let response = response as? HTTPURLResponse else {
        throw QiitaItemsModelError.invalidResponse
      }
            
      if response.statusCode == 200 {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let items = try decoder.decode([QiitaItem].self, from: data)
        return items
      } else {
        throw QiitaItemsModelError.invalidStatusCode(code: response.statusCode)
      }
    } catch {
      throw error
    }
  }
  
  private func urlBuilder(by word: String) -> (URL?, Error?) {
    guard let query = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
      return (nil, QiitaItemsModelError.encodingError)
    }
    var urlComponents = baseURL
    urlComponents.path = "/api/v2/items"
    urlComponents.queryItems = [URLQueryItem(name: "query", value: "title:\(query)")]
    guard let url = urlComponents.url else {
      return (nil, QiitaItemsModelError.invalidURL)
    }
    
    return (url, nil)
  }
  
  private func loadToken() -> String {
    guard let fileURL = Bundle.main.url(forResource: "token", withExtension: "txt"),
          let token = try? String(contentsOf: fileURL, encoding: .utf8) else {
            fatalError("読み込み出来ません")
          }
    return token
  }
}

// MARK: - カスタムエラー
enum QiitaItemsModelError: Error {
  case invalidURL
  case invalidResponse
  case invalidStatusCode(code: Int)
  case encodingError
}

extension QiitaItemsModelError: LocalizedError {
  var errorDescription: String? {
    switch self {
      case .invalidURL:
        return "無効なURLです"
      case .invalidResponse:
        return "無効なレスポンスです"
      case .invalidStatusCode(let code):
        return "エラーのステータスコードです: \(code)"
      case .encodingError:
        return "検索ワードのエンコードに失敗"
    }
  }
}
