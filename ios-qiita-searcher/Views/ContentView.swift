//
//  ContentView.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/19.
//

import SwiftUI
import Combine

struct ContentView: View {
  @StateObject var qiitaItemsViewModel: QiitaItemsViewModel
  
  var body: some View {
    NavigationView {
      ZStack {
        VStack(spacing: 5) {
          VStack(spacing: 5) {
            HStack(spacing: 5) {
              TextField("検索ワード", text: self.$qiitaItemsViewModel.searchWord)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                  self.qiitaItemsViewModel.submit()
                }
              Button("検索") {
                self.qiitaItemsViewModel.submit()
              }
            }
            HStack(spacing: 2) {
              Spacer()
              Image(systemName: "arrow.up.arrow.down.circle.fill")
              Picker("ソート", selection: self.$qiitaItemsViewModel.sortTarget) {
                ForEach(QiitaItem.SortTargets.allCases) { t in
                  Text(t.rawValue).tag(t)
                }
              }
            }
          }
          .padding()
          
          if self.qiitaItemsViewModel.isEmpty {
            List {
              Text("検索結果がありません")
            }
            .refreshable {
              self.qiitaItemsViewModel.submit()
            }
            .listStyle(PlainListStyle())
          } else {
            List(self.$qiitaItemsViewModel.items) { $item in
              NavigationLink {
                DetailView(item: $item)
              } label: {
                Text(item.title)
                  .lineLimit(1)
              }
            }
            .refreshable {
              self.qiitaItemsViewModel.submit()
            }
            .listStyle(PlainListStyle())
          }
        }
        if self.qiitaItemsViewModel.isLoading {
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
