//
//  MainActorSubstore.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

@MainActor
public final class MainActorSubstore<State: StoreStateProtocol, Action>: StoreProtocol {
  private let parentStore: AnyStore<State, Action>
  private let storeUpdatesObserver: StoreUpdatesObserver
  
  public var storeUpdatesStream: StoreUpdatesStream { get async { await storeUpdatesObserver.values() } }
  public var state: State
  
  convenience init<ParentStore: StoreProtocol>(parentStore: ParentStore) async where ParentStore: AnyObject, ParentStore.State == State, ParentStore.Action == Action {
    await self.init(state: parentStore.state, parentStore: parentStore)
  }
  
  init<ParentStore: StoreProtocol>(
    state: State,
    parentStore: ParentStore
  ) where ParentStore: AnyObject, ParentStore.State == State, ParentStore.Action == Action {
    self.parentStore = AnyStore(store: parentStore)
    self.state = state
    self.storeUpdatesObserver = Self.makeUpdatesObserver()
    
    Task { [weak self, weak parentStore] in
      guard let parentStoreUpdatesStream = await parentStore?.storeUpdatesStream else { return }
      
      for await parentStoreUpdate in parentStoreUpdatesStream {
        await MainActor.run { self?.state = parentStoreUpdate.state }
        await self?.storeUpdatesObserver.publishValue(parentStoreUpdate)
      }
    }
  }
  
  public nonisolated func postAction(_ action: sending Action) async {
    await parentStore.postAction(action)
  }
}
