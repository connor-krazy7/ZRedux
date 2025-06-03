//
//  StoreProtocol+Extensions.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public extension StoreProtocol {
  typealias StoreUpdatesObserver = AsyncObserver<StoreUpdate<State>>
  
  static func makeUpdatesObserver() -> StoreUpdatesObserver {
    StoreUpdatesObserver(bufferSize: 1)
  }
}

public extension StoreProtocol {
  func asAnyStore() -> AnyStore<State, Action> {
    AnyStore(store: self)
  }
  
  // MARK: - enrichAction
  
  func enrichAction<ActionEnricher: StoreActionEnricherProtocol>(
    actionEnricher: ActionEnricher
  ) -> EnrichedActionStore<State, ActionEnricher.Action, ActionEnricher.EnrichedAction> where ActionEnricher.State == State, ActionEnricher.EnrichedAction == Action {
    EnrichedActionStore(parentStore: self, actionEnricher: actionEnricher)
  }
  
  func enrichAction<NewAction>(
    enrichAction: @escaping StoreActionEnricherClosure<NewAction, State, Action>
  ) -> EnrichedActionStore<State, NewAction, Action> {
    self.enrichAction(actionEnricher: CustomStoreActionEnricher(enrichAction: enrichAction))
  }

  func enrichAction<NewAction>(
    _: NewAction.Type,
    by enrichAction: @escaping StoreActionEnricherClosure<NewAction, State, Action>
  ) -> EnrichedActionStore<State, NewAction, Action> {
    self.enrichAction(actionEnricher: CustomStoreActionEnricher(enrichAction: enrichAction))
  }
  
  // MARK: - eraseActionType

  func eraseActionType<ActionMapper: StoreActionMapperProtocol>(
    erasedActionMapper: ActionMapper
  ) -> ErasedActionTypeStore<State, ActionMapper.Action, Action> where ActionMapper.ParentStoreAction == Action {
    ErasedActionTypeStore(parentStore: self, actionMapper: erasedActionMapper)
  }
  
  func eraseActionType<NewAction>(
    mapErasedAction: @escaping StoreActionMapperClosure<NewAction, Action>
  ) -> ErasedActionTypeStore<State, NewAction, Action> {
    eraseActionType(erasedActionMapper: CustomStoreActionMapper(mapAction: mapErasedAction))
  }
  
  func eraseActionType<NewAction>(
    to newAction: NewAction.Type,
    mapErasedAction: @escaping StoreActionMapperClosure<NewAction, Action>
  ) -> ErasedActionTypeStore<State, NewAction, Action> {
    eraseActionType(mapErasedAction: mapErasedAction)
  }
}

// MARK: - Store Object + Extensions

public extension StoreProtocol where Self: AnyObject {
  @MainActor
  func asViewStore() -> ViewStore<State, Action> {
    ViewStore(parentStore: self)
  }
  
  func asMainActorStore() async -> MainActorSubstore<State, Action> {
    await MainActorSubstore(parentStore: self)
  }
  
  // MARK: - ScopeState

  func scopeState<StateMapper: StoreStateMapperProtocol>(
    stateMapper: StateMapper
  ) -> ScopedStateStore<StateMapper.State, Action, StateMapper.ParentStoreState> where StateMapper.ParentStoreState == State {
    ScopedStateStore(parentStore: self, stateMapper: stateMapper)
  }
  
  func scopeState<NewState: StoreStateProtocol>(
    _ mapState: @escaping StoreStateMapperClosure<State, NewState>
  ) -> ScopedStateStore<NewState, Action, State> {
    scopeState(stateMapper: CustomStoreStateMapper(mapState: mapState))
  }
}
