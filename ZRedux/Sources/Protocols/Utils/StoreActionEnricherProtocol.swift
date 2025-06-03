//
//  StoreActionEnricherProtocol.swift
//  App
//
//  Created by Artsem Hotsau on 23.05.25.
//

import Foundation

public protocol StoreActionEnricherProtocol: Sendable {
  associatedtype Action
  associatedtype State
  associatedtype EnrichedAction
  
  func enrichedAction(_ action: Action, with state: State) -> EnrichedAction?
}

public typealias StoreActionEnricherClosure<Action, State, EnrichedAction> = @Sendable (_ action: Action, _ state: State) -> EnrichedAction?

public struct CustomStoreActionEnricher<Action, State, EnrichedAction>: Sendable, StoreActionEnricherProtocol {
  private let enrichAction: StoreActionEnricherClosure<Action, State, EnrichedAction>
  
  public init(enrichAction: @escaping StoreActionEnricherClosure<Action, State, EnrichedAction>) {
    self.enrichAction = enrichAction
  }

  public func enrichedAction(_ action: Action, with state: State) -> EnrichedAction? {
    enrichAction(action, state)
  }
}
