//
//  EffectExecutors.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public enum PredefinedTaskEffectExecutors: EffectExecutorProtocol {
  public func executeEffect<
    Effect: ReducerEffectProtocol,
    ActionDispatcher: StoreActionDispatcherProtocol
  >(_ effect: Effect, actionDispatcher: ActionDispatcher) where Effect.Action == ActionDispatcher.Action { }
}

public extension EffectExecutorProtocol where Self == PredefinedTaskEffectExecutors {
  static var taskExecutor: EffectExecutorProtocol { TaskEffectExecutor() }
  static var detachedTaskExecutor: EffectExecutorProtocol { DetachedTaskEffectExecutor() }
}

// MARK: - Implementation

struct TaskEffectExecutor: EffectExecutorProtocol {
  private func taskPriority<Effect: ReducerEffectProtocol>(effect: Effect) -> TaskPriority? {
    switch effect.priority {
    case .high: .high
    case .medium: .medium
    case .low: .low
    case .userInitiated: .userInitiated
    case .utility: .utility
    case .background: .background
    case nil: nil
    }
  }
  
  func executeEffect<
    Effect: ReducerEffectProtocol,
    ActionDispatcher: StoreActionDispatcherProtocol
  >(_ effect: Effect, actionDispatcher: ActionDispatcher) where Effect.Action == ActionDispatcher.Action {
    guard !effect.hasNoEffect else { return }
    Task(priority: taskPriority(effect: effect)) { await effect.execute(with: actionDispatcher) }
  }
}

struct DetachedTaskEffectExecutor: EffectExecutorProtocol {
  private func taskPriority<Effect: ReducerEffectProtocol>(effect: Effect) -> TaskPriority? {
    switch effect.priority {
    case .high: .high
    case .medium: .medium
    case .low: .low
    case .userInitiated: .userInitiated
    case .utility: .utility
    case .background: .background
    case nil: nil
    }
  }
  
  func executeEffect<
    Effect: ReducerEffectProtocol,
    ActionDispatcher: StoreActionDispatcherProtocol
  >(_ effect: Effect, actionDispatcher: ActionDispatcher) where Effect.Action == ActionDispatcher.Action {
    guard !effect.hasNoEffect else { return }
    Task.detached(priority: taskPriority(effect: effect)) { await effect.execute(with: actionDispatcher) }
  }
}
