//
//  ContentView.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/19.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var model: QiitaItemsModel
  weak var delegate: QiitaItemsViewProtocol?
  @State private var searchWord = ""
  @State private var sortTarget: QiitaItem.SortTargets = .title
  
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
                    await delegate?.loadData(by: searchWord, sort: sortTarget)
                  }
                }
              Button("検索") {
                Task {
                  await delegate?.loadData(by: searchWord, sort: sortTarget)
                }
              }
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
                Task {
                  await delegate?.sortItem(by: newValue)
                }
              })
            }
          }
          .padding()
          
          if self.model.isEmpty {
            List {
              Text("検索結果がありません")
            }
            .refreshable {
              Task {
                await delegate?.loadData(by: searchWord, sort: sortTarget)
              }
            }
            .listStyle(PlainListStyle())
          } else {
            List($model.items) { $item in
              NavigationLink {
                DetailView(item: $item)
              } label: {
                Text(item.title)
                  .lineLimit(1)
              }
            }
            .refreshable {
              Task {
                await delegate?.loadData(by: searchWord, sort: sortTarget)
              }
            }
            .listStyle(PlainListStyle())
          }
        }
        if model.isLoading {
          ProgressView()
            .scaleEffect(x: 3, y: 3, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle())
        }
      }
      .navigationTitle("Qiita検索")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
}
