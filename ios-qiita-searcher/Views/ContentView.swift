//
//  ContentView.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/19.
//

import SwiftUI

struct ContentView: View, QiitaItemsPresenterOutput {
  weak var presenter: QiitaItemsPresenterInput?
  @State private var searchWord = ""
  @State private var sortTarget: QiitaItem.SortTargets = .title
  @State private var items: [QiitaItem] = []
  @State private var isEmpty: Bool = false
  @State private var isLoading: Bool = false
  @State private var error: String?
  
  var body: some View {
    NavigationView {
      ZStack {
        VStack(spacing: 5) {
          VStack(spacing: 5) {
            HStack(spacing: 5) {
              TextField("検索ワード", text: $searchWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                  Task {
                    await presenter?.search(in: searchWord, orderBy: sortTarget)
                  }
                }
              Button("検索") {
                Task {
                  await presenter?.search(in: searchWord, orderBy: sortTarget)
                }
              }
            }
            if let error = error {
              Text(error)
                .foregroundColor(.red)
            }
            HStack(spacing: 2) {
              Spacer()
              Image(systemName: "arrow.up.arrow.down.circle.fill")
              Picker("ソート", selection: $sortTarget) {
                ForEach(QiitaItem.SortTargets.allCases) { t in
                  Text(t.rawValue).tag(t)
                }
              }
              .onChange(of: sortTarget, perform: { newValue in
                presenter?.sort(orderBy: newValue)
              })
            }
          }
          .padding()
          
          if self.isEmpty {
            List {
              Text("検索結果がありません")
            }
            .refreshable {
              Task {
                await presenter?.search(in: searchWord, orderBy: sortTarget)
              }
            }
            .listStyle(PlainListStyle())
          } else {
            List(self.$items) { $item in
              Text(item.title)
                .lineLimit(1)
            }
            .refreshable {
              Task {
                await presenter?.search(in: searchWord, orderBy: sortTarget)
              }
            }
            .listStyle(PlainListStyle())
          }
        }
        if self.isLoading {
          ProgressView()
            .scaleEffect(x: 3, y: 3, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle())
        }
      }
      .navigationTitle("Qiita検索")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  func updateItems(by items: [QiitaItem]) {
    print("======== in ========")
    items.forEach { print($0.title) }
    self.items = items
    self.isEmpty = (items.count == 0)
    print("======== result ========")
    self.items.forEach { print($0.title) }
    print(self.isEmpty)
  }
  
  func showError(msg: String) {
    self.error = msg
  }
  
  func hideError() {
    self.error = nil
  }
  
  func startSearch() {
    self.isLoading = true
  }
  
  func endSearch() {
    self.isLoading = false
  }
}
