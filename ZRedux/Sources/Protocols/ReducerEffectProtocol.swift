//
//  AsyncReducerEffectProtocol.swift
//  App
//
//  Created by Artsem Hotsau on 22.05.25.
//

import Foundation

public enum ReducerEffectPriority: Sendable {
  case high
  case medium
  case low
  case userInitiated
  case utility
  case background
}

public protocol ReducerEffectProtocol: Sendable {
  associatedtype Action
  
  var priority: ReducerEffectPriority? { get }
  var hasNoEffect: Bool { get }
  
  func execute<ActionDispatcher: StoreActionDispatcherProtocol>(with actionDispatcher: ActionDispatcher) async where ActionDispatcher.Action == Action
}
