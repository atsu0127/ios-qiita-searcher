//
//  Repository.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/04/08.
//

import Foundation

struct QiitaRepository {
    // MARK: - Varuables
    private var baseURL: URLComponents {
      var components = URLComponents()
      components.scheme = "https"
      components.host = "qiita.com"
      return components
    }
    
    // MARK: - Callable Functions    
    func search(by word: String) async throws -> [QiitaItem] {
      let (url, error) = urlBuilder(by: word)
      if let error = error {
        print("url作成でエラー: \(error.localizedDescription)")
        throw error
      }
      
      guard let url = url else {
        print("urlが取得できませんでした")
        throw QiitaRepositoryError.invalidURL
      }

      do {
        let data = try await fetch(to: url)
        return data
      } catch {
        print("データ取得でエラー: \(error.localizedDescription)")
        print(error)
        throw error
      }
    }
    
    // MARK: - Support Functions
    private func fetch(to url: URL) async throws -> [QiitaItem] {
      do {
        var request = URLRequest(url: url)
        let token = loadToken()
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
          throw QiitaRepositoryError.invalidResponse
        }
              
        if response.statusCode == 200 {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = .iso8601
          let items = try decoder.decode([QiitaItem].self, from: data)
          return items
        } else {
          throw QiitaRepositoryError.invalidStatusCode(code: response.statusCode)
        }
      } catch {
        throw error
      }
    }
    
    private func urlBuilder(by word: String) -> (URL?, Error?) {
      guard let query = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        return (nil, QiitaRepositoryError.encodingError)
      }
      var urlComponents = baseURL
      urlComponents.path = "/api/v2/items"
      urlComponents.queryItems = [URLQueryItem(name: "query", value: "title:\(query)")]
      guard let url = urlComponents.url else {
        return (nil, QiitaRepositoryError.invalidURL)
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
  enum QiitaRepositoryError: Error {
    case invalidURL
    case invalidResponse
    case invalidStatusCode(code: Int)
    case encodingError
  }

  extension QiitaRepositoryError: LocalizedError {
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
