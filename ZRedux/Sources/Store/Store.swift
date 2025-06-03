//
//  Store.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public actor Store<State: StoreStateProtocol, Action>: StoreProtocol {
  private let reducer: AnyReducer<Action, State>
  private let effectExecutor: EffectExecutorProtocol
  private let storeUpdatesObserver: StoreUpdatesObserver
  
  public var storeUpdatesStream: StoreUpdatesStream { get async { await storeUpdatesObserver.values() } }
  public var state: State
  
  public init<Reducer: ReducerProtocol>(
    state: State,
    reducer: Reducer,
    effectExecutor: EffectExecutorProtocol = .taskExecutor
  ) where Reducer.State == State, Reducer.Action == Action {
    self.state = state
    self.reducer = AnyReducer(reducer: reducer)
    self.effectExecutor = effectExecutor
    self.storeUpdatesObserver = Self.makeUpdatesObserver()
  }
  
  private func _postAction(_ action: sending Action) async {
    var newState = state
    
    let effect = reducer.reduce(state: &newState, action: action)
    let newUpdate = StoreUpdate(newState: newState, oldState: state)
    
    effectExecutor.executeEffect(effect, actionDispatcher: self)
    
    guard !newUpdate.keyPaths.isEmpty else { return }
    
    state = newState
    await storeUpdatesObserver.publishValue(newUpdate)
  }
  
  public nonisolated func postAction(_ action: sending Action) async {
    await _postAction(action)
  }
}
