//
//  AnyStoreActionEnricher.swift
//  App
//
//  Created by Artsem Hotsau on 23.05.25.
//

import Foundation

public struct AnyStoreActionEnricher<Action, State, EnrichedAction>: Sendable, StoreActionEnricherProtocol {
  private let actionEnricher: BaseStoreActionEnricher<Action, State, EnrichedAction>
  
  public init<ActionEnricher: StoreActionEnricherProtocol>(
    actionEnricher: ActionEnricher
  ) where ActionEnricher.Action == Action, ActionEnricher.State == State, ActionEnricher.EnrichedAction == EnrichedAction {
    self.actionEnricher = ConcreteStoreActionEnricher(actionEnricher: actionEnricher)
  }

  public func enrichedAction(_ action: Action, with state: State) -> EnrichedAction? {
    actionEnricher.enrichedAction(action, with: state)
  }
}

private final class ConcreteStoreActionEnricher<ActionEnricher: StoreActionEnricherProtocol>: BaseStoreActionEnricher<ActionEnricher.Action,
                                                                                      ActionEnricher.State,
                                                                                      ActionEnricher.EnrichedAction>,
                                                                                      @unchecked Sendable {
  private let actionEnricher: ActionEnricher
  
  init(actionEnricher: ActionEnricher) {
    self.actionEnricher = actionEnricher
  }
  
  override func enrichedAction(_ action: Action, with state: State) -> EnrichedAction? {
    actionEnricher.enrichedAction(action, with: state)
  }
}

private class BaseStoreActionEnricher<Action, State, EnrichedAction>: @unchecked Sendable, StoreActionEnricherProtocol {
  func enrichedAction(_ action: Action, with state: State) -> EnrichedAction? {
    preconditionFailure("Abstract")
  }
}
