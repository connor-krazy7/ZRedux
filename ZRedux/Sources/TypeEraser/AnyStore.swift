//
//  AnyStore.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public final class AnyStore<State: StoreStateProtocol, Action>: StoreProtocol {
  private let store: BaseStore<State, Action>
  
  public init<Store: StoreProtocol>(store: Store) where Store.Action == Action, Store.State == State {
    self.store = ConcreteStore(store: store)
  }
  
  public var storeUpdatesStream: StoreUpdatesStream { get async { await store.storeUpdatesStream } }
  public var state: State { get async { await store.state } }

  public func postAction(_ action: sending Action) async {
    await store.postAction(action)
  }
}

private final class ConcreteStore<Store: StoreProtocol>: BaseStore<Store.State, Store.Action>, @unchecked Sendable {
  private let store: Store
  
  init(store: Store) {
    self.store = store
  }
  
  override var storeUpdatesStream: StoreUpdatesStream { get async { await store.storeUpdatesStream } }
  override var state: Store.State { get async { await store.state } }
  
  override func postAction(_ action: sending Store.Action) async {
    await store.postAction(action)
  }
}

private class BaseStore<State: StoreStateProtocol, Action>: @unchecked Sendable, StoreProtocol {
  var storeUpdatesStream: StoreUpdatesStream { get async { preconditionFailure("abstract") } }
  var state: State { get async { preconditionFailure("abstract") } }
  
  func postAction(_ action: sending Action) async {
    preconditionFailure("abstract")
  }
}
