//
//  AnyReducerEffect.swift
//  App
//
//  Created by Artsem Hotsau on 22.05.25.
//

import Foundation

public final class AnyReducerEffect<Action>: Sendable, ReducerEffectProtocol {
  public var priority: ReducerEffectPriority? { effect.priority }
  public var hasNoEffect: Bool { effect.hasNoEffect }
  
  private let effect: BaseReducerEffect<Action>
  
  public init<Effect: ReducerEffectProtocol>(effect: Effect) where Effect.Action == Action {
    self.effect = ConcreteReducerEffect(effect: effect)
  }
  
  public func execute<ActionDispatcher>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher: StoreActionDispatcherProtocol, ActionDispatcher.Action == Action {
    await effect.execute(with: actionDispatcher)
  }
}

private final class ConcreteReducerEffect<Effect: ReducerEffectProtocol>: BaseReducerEffect<Effect.Action>, @unchecked Sendable {
  private let effect: Effect
  
  init(effect: Effect) {
    self.effect = effect
  }
  
  override var priority: ReducerEffectPriority? { effect.priority }
  override var hasNoEffect: Bool { effect.hasNoEffect }
  
  override func execute<ActionDispatcher>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher: StoreActionDispatcherProtocol, ActionDispatcher.Action == Action {
    await effect.execute(with: actionDispatcher)
  }
}

private class BaseReducerEffect<Action>: @unchecked Sendable, ReducerEffectProtocol {
  var priority: ReducerEffectPriority? { preconditionFailure("abstract") }
  var hasNoEffect: Bool { preconditionFailure("abstract") }
  
  func execute<ActionDispatcher>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher: StoreActionDispatcherProtocol, ActionDispatcher.Action == Action {
    preconditionFailure("abstract")
  }
}
