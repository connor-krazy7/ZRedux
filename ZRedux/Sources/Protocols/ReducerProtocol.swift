//
//  ReducerProtocol.swift
//  App
//
//  Created by Artsem Hotsau on 20.05.25.
//

import Foundation

public protocol ReducerConstraintsProtocol: Sendable {
  associatedtype Action
  associatedtype State: StoreStateProtocol
}

public protocol ReducerProtocol: ReducerConstraintsProtocol {
  func reduce(state: inout State, action: sending Action) -> sending AnyReducerEffect<Action>
}
