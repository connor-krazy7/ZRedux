//
//  ScopedStateStore.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public actor ScopedStateStore<State: StoreStateProtocol, Action, ParentState: StoreStateProtocol>: StoreProtocol {
  private let parentStore: AnyStore<ParentState, Action>
  private let stateMapper: AnyStoreStateMapper<ParentState, State>
  private let storeUpdatesObserver: StoreUpdatesObserver
  private nonisolated(unsafe) var parentStoreObservingTask: Task<Void, Error>?
  private var _state: State?
  
  public var storeUpdatesStream: StoreUpdatesStream { get async { await storeUpdatesObserver.values() } }
  
  public var state: State {
    get async {
      let existingState: State
      defer { _state = existingState }
      
      if let _state {
        existingState = _state
      } else {
        existingState = await stateMapper.state(parentState: parentStore.state)
      }
      
      return existingState
    }
  }
  
  init<ParentStore: StoreProtocol, StateMapper: StoreStateMapperProtocol>(
    parentStore: ParentStore,
    stateMapper: StateMapper
  ) where ParentStore: AnyObject, ParentStore.State == ParentState, ParentStore.Action == Action, StateMapper.ParentStoreState == ParentStore.State, StateMapper.State == State {
    self.parentStore = AnyStore(store: parentStore)
    self.stateMapper = AnyStoreStateMapper(mapper: stateMapper)
    self.storeUpdatesObserver = Self.makeUpdatesObserver()
    // FIXME: create some generic method for all Stores that would allows such custom setup
    self.parentStoreObservingTask = Task { [weak parentStore, weak self, stateMapper] in
      let parentStoreUpdatesStream = await parentStore?.storeUpdatesStream
      let oldState = await (parentStore?.state).map(stateMapper.state(parentState:))
      
      try Task.checkCancellation()
      
      guard let parentStoreUpdatesStream, var oldState else { return }
      
      for await parentStoreUpdate in parentStoreUpdatesStream {
        try Task.checkCancellation()
        
        let newState = stateMapper.state(parentState: parentStoreUpdate.state)
        let newUpdate = StoreUpdate(newState: newState, oldState: oldState)
        
        guard !newUpdate.keyPaths.isEmpty else { return}
        
        oldState = newState
        await self?.setState(newState)
        await self?.storeUpdatesObserver.publishValue(newUpdate)
        
        try Task.checkCancellation()
      }
    }
  }
  
  deinit {
    parentStoreObservingTask?.cancel()
  }

  private func setState(_ state: State) {
    self._state = state
  }
  
  public nonisolated func postAction(_ action: sending Action) async {
    await parentStore.postAction(action)
  }
}
