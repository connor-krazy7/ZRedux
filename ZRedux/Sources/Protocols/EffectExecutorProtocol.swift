//
//  EffectExecutorProtocol.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public protocol EffectExecutorProtocol {
  func executeEffect<
    Effect: ReducerEffectProtocol,
    ActionDispatcher: StoreActionDispatcherProtocol
  >(_ effect: Effect, actionDispatcher: ActionDispatcher) where Effect.Action == ActionDispatcher.Action
}
