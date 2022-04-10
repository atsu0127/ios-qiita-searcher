//
//  Store.swift
//  ios-qiita-searcher
//
//  Created by atabata on 2022/04/08.
//

import Foundation

typealias Subscription = NSObjectProtocol

class Store: ObservableObject {
  private lazy var dispatchToken: DispatchToken = {
    return dispatcher.register { [weak self] action in
      self?.onDispatch(action)
    }
  }()
  private let dispatcher: Dispatcher
  
  deinit {
    dispatcher.unregister(dispatchToken)
  }
  
  init(dispatcher: Dispatcher) {
    self.dispatcher = dispatcher
    _ = dispatchToken
  }

  func onDispatch(_ action: Action) {
    fatalError("must override")
  }
}
