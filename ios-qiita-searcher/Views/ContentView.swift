//
//  ContentView.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/19.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject private var searchItemStore: SearchItemStore = .shared
  @State private var searchWord = ""
  @State private var sortTarget: QiitaItem.SortTargets = .title
  private var actionCreator: ActionCreator = .init()
  
  func searchItems(by keyword: String, orderBy target: QiitaItem.SortTargets) async {
    actionCreator.startLoad()
    await actionCreator.searchItems(by: searchWord, orderBy: sortTarget)
    actionCreator.stopLoad()
  }
  
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
                    
                    
                  }
                }
              Button("検索") {
                Task {
                  await searchItems(by: searchWord, orderBy: sortTarget)
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
                  actionCreator.sortItems(by: newValue)
                }
              })
            }
          }
          .padding()
          
          if self.searchItemStore.isEmpty {
            List {
              Text("検索結果がありません")
            }
            .refreshable {
              Task {
                await searchItems(by: searchWord, orderBy: sortTarget)
              }
            }
            .listStyle(PlainListStyle())
          } else {
            List(self.$searchItemStore.items) { $item in
              NavigationLink {
                DetailView(item: $item)
              } label: {
                Text(item.title).lineLimit(1)
              }
            }
            .refreshable {
              Task {
                await searchItems(by: searchWord, orderBy: sortTarget)
              }
            }
            .listStyle(PlainListStyle())
          }
        }
        if self.searchItemStore.isLoading {
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
