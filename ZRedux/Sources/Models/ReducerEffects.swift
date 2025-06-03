//
//  ReducerEffectS.swift
//  App
//
//  Created by Artsem Hotsau on 22.05.25.
//

import Foundation

public extension AnyReducerEffect {
  typealias TaskOperationClosure = @Sendable () async -> sending Action?
  typealias ActionTaskOperationClosure = @Sendable () async -> sending Action
  typealias NoActionTaskOperationClosure = @Sendable () async -> Void
  
  typealias ContinuationSendActionClosure = @Sendable(_ action: sending Action) async -> Void
  typealias ContinuationClosure = @Sendable (_ sendAction: @escaping ContinuationSendActionClosure) async -> Void
  typealias NoActionContinuationClosure = @Sendable () async -> Void
  
  static func task(priority: ReducerEffectPriority? = nil, operation: @escaping TaskOperationClosure) -> AnyReducerEffect<Action> {
    TaskReducerEffect(priority: priority, operation: operation).asAnyEffect()
  }
  
  static func actionTask(priority: ReducerEffectPriority? = nil, operation: @escaping ActionTaskOperationClosure) -> AnyReducerEffect<Action> {
    task(priority: priority, operation: operation)
  }
  
  static func noActionTask(priority: ReducerEffectPriority? = nil, operation: @escaping NoActionTaskOperationClosure) -> AnyReducerEffect<Action> {
    task(priority: priority, operation: { await operation(); return nil })
  }
  
  static func continuation(priority: ReducerEffectPriority? = nil, contiunuation: @escaping ContinuationClosure) -> AnyReducerEffect<Action> {
    ContinuationReducerEffect(priority: priority, contiunuation: contiunuation).asAnyEffect()
  }
  
  static func noActionContinuation(priority: ReducerEffectPriority? = nil, contiunuation: @escaping NoActionContinuationClosure) -> AnyReducerEffect<Action> {
    continuation(priority: priority, contiunuation: { _ in await contiunuation() })
  }

  static var noEffect: AnyReducerEffect<Action> {
    ReducerNoEffect().asAnyEffect()
  }
}

public extension AnyReducerEffect where Action: Sendable {
  static func asyncStream(priority: ReducerEffectPriority? = nil, stream: AsyncStream<Action>) -> AnyReducerEffect<Action> {
    AsyncStreamReducerEffect(priority: priority, stream: stream).asAnyEffect()
  }
  
  static func asyncStream(
    priority: ReducerEffectPriority? = nil,
    bufferingPolicy: AsyncStream<Action>.Continuation.BufferingPolicy,
    _ buildStream: (_ continuation: AsyncStream<Action>.Continuation) -> Void
  ) -> AnyReducerEffect<Action> {
    asyncStream(priority: priority, stream: AsyncStream(bufferingPolicy: bufferingPolicy, buildStream))
  }
}

// MARK: - Implementation

private struct TaskReducerEffect<Action>: Sendable, ReducerEffectProtocol {
  var priority: ReducerEffectPriority?
  var operation: @Sendable () async -> Action?
  var hasNoEffect: Bool { false }
  
  func execute<ActionDispatcher: StoreActionDispatcherProtocol>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher.Action == Action {
    guard let action = await operation() else { return }
    await actionDispatcher.postAction(action)
  }
}

private struct ContinuationReducerEffect<Action>: Sendable, ReducerEffectProtocol {
  typealias SendActionClosure = @Sendable (_ action: sending Action?) async -> Void
  typealias ContinuationClosure = @Sendable (_ sendAction: @escaping SendActionClosure) async -> Void
  
  var priority: ReducerEffectPriority?
  var contiunuation: ContinuationClosure
  var hasNoEffect: Bool { false }
  
  func execute<ActionDispatcher: StoreActionDispatcherProtocol>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher.Action == Action {
    await contiunuation { [weak actionDispatcher] action in
      guard let action else { return }
      await actionDispatcher?.postAction(action)
    }
  }
}

private struct AsyncStreamReducerEffect<Action: Sendable>: Sendable, ReducerEffectProtocol {
  let priority: ReducerEffectPriority?
  let stream: AsyncStream<Action>
  var hasNoEffect: Bool { false }
  
  func execute<ActionDispatcher: StoreActionDispatcherProtocol>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher.Action == Action {
    for await action in stream {
      await actionDispatcher.postAction(action)
    }
  }
}

private struct ReducerNoEffect<Action>: Sendable, ReducerEffectProtocol {
  var priority: ReducerEffectPriority? { nil }
  var hasNoEffect: Bool { true }
  func execute<ActionDispatcher: StoreActionDispatcherProtocol>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher.Action == Action { }
}
