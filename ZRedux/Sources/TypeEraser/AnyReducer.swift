//
//  AnyReducer.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public final class AnyReducer<Action, State: StoreStateProtocol>: ReducerProtocol {
  private let reducer: BaseReducer<Action, State>
  
  public init<Reducer: ReducerProtocol>(reducer: Reducer) where Reducer.Action == Action, Reducer.State == State {
    self.reducer = ConcreteReducer(reducer: reducer)
  }

  public func reduce(state: inout State, action: sending Action) -> sending AnyReducerEffect<Action> {
    reducer.reduce(state: &state, action: action)
  }
}

private final class ConcreteReducer<Reducer: ReducerProtocol>: BaseReducer<Reducer.Action, Reducer.State>, @unchecked Sendable {
  private let reducer: Reducer
  
  init(reducer: Reducer) {
    self.reducer = reducer
  }
  
  override func reduce(state: inout State, action: sending Action) -> sending AnyReducerEffect<Action> {
    reducer.reduce(state: &state, action: action)
  }
}

private class BaseReducer<Action, State: StoreStateProtocol>: @unchecked Sendable, ReducerProtocol {
  func reduce(state: inout State, action: sending Action) -> sending AnyReducerEffect<Action> {
    preconditionFailure("abstract")
  }
}
