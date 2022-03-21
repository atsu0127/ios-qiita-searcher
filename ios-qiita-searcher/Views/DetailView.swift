//
//  DetailView.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/03/21.
//

import SwiftUI
import Parma

struct DetailView: View {
  @Binding var item: QiitaItem
  
  var body: some View {
    GeometryReader { geo in
      ZStack {
        ScrollView {
          VStack(spacing: 10) {
            Text(item.title)
              .font(.title)
              .lineLimit(nil)
            
            Parma(item.body)
          }
        }
        if let url = URL(string: item.url) {
          Link(destination: url) {
            Text("Qiitaで開く")
              .foregroundColor(.black)
              .padding(5)
              .frame(width: geo.size.width / 3, height: geo.size.width / 9, alignment: .center)
              .background(Color.green)
              .opacity(0.7)
              .clipShape(Capsule())
          }
          .offset(y: geo.size.height / 2 - 20)
        }
      }
      .padding()
    }
  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    DetailView(item: .constant(QiitaItem.mock))
  }
}
