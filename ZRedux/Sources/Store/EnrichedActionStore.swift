//
//  EnrichedActionStore.swift
//  App
//
//  Created by Artsem Hotsau on 23.05.25.
//

import Foundation

public final class EnrichedActionStore<State: StoreStateProtocol, Action, EnrichedAction>: StoreProtocol {
  private let parentStore: AnyStore<State, EnrichedAction>
  private let actionEnricher: AnyStoreActionEnricher<Action, State, EnrichedAction>
  
  public var storeUpdatesStream: StoreUpdatesStream { get async { await parentStore.storeUpdatesStream } }
  public var state: State { get async { await parentStore.state } }
  
  init<ParentStore: StoreProtocol, ActionEnricher: StoreActionEnricherProtocol>(
    parentStore: ParentStore,
    actionEnricher: ActionEnricher
  ) where ParentStore.Action == EnrichedAction, ParentStore.State == State, ActionEnricher.Action == Action, ActionEnricher.State == State, ActionEnricher.EnrichedAction == EnrichedAction {
    self.parentStore = AnyStore(store: parentStore)
    self.actionEnricher = AnyStoreActionEnricher(actionEnricher: actionEnricher)
  }
  
  public func postAction(_ action: sending Action) async {
    guard let enrichedAction = await actionEnricher.enrichedAction(action, with: parentStore.state) else { return }
    await parentStore.postAction(enrichedAction)
  }
}
