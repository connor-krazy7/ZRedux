//
//  ErasedActionTypeStore.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public final class ErasedActionTypeStore<State: StoreStateProtocol, Action, ParentAction>: StoreProtocol {
  private let parentStore: AnyStore<State, ParentAction>
  private let actionMapper: AnyStoreActionMapper<Action, ParentAction>
  
  public var storeUpdatesStream: StoreUpdatesStream { get async { await parentStore.storeUpdatesStream } }
  public var state: State { get async { await parentStore.state } }
  
  init<ParentStore: StoreProtocol, ActionMapper: StoreActionMapperProtocol>(
    parentStore: ParentStore,
    actionMapper: ActionMapper
  ) where ParentStore.Action == ParentAction, ParentStore.State == State, ActionMapper.Action == Action, ActionMapper.ParentStoreAction == ParentStore.Action {
    self.parentStore = AnyStore(store: parentStore)
    self.actionMapper = AnyStoreActionMapper(actionMapper: actionMapper)
  }
  
  public func postAction(_ action: sending Action) async {
    await parentStore.postAction(actionMapper.parentAction(action))
  }
}
