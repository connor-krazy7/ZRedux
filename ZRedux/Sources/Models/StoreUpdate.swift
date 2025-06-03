//
//  StoreUpdate.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public struct StoreUpdate<State: StoreStateProtocol>: Sendable {
  let state: State
  nonisolated(unsafe) let keyPaths: Set<State.DifferentiableKeyPath>
  
  init(newState: State, oldState: State) where State: StoreStateProtocol {
    self.state = newState
    self.keyPaths = newState.difference(from: oldState)
  }
}
