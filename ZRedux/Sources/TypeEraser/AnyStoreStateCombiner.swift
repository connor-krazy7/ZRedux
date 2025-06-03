//
//  AnyStoreStateCombiner.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public final class AnyStoreStateCombiner<
  State1: StoreStateProtocol,
  State2: StoreStateProtocol,
  FinalState: StoreStateProtocol
>: @unchecked Sendable, StoreStateCombinerProtocol {
  private let combiner: BaseStoreStateCombiner<State1, State2, FinalState>
  
  init<Combiner: StoreStateCombinerProtocol>(combiner: Combiner) where Combiner.State1 == State1, Combiner.State2 == State2, Combiner.FinalState == FinalState {
    self.combiner = ConcreteStoreStateCombiner(combiner: combiner)
  }

  public func combineStates(state1: State1, state2: State2) -> FinalState {
    combiner.combineStates(state1: state1, state2: state2)
  }
}

public extension AnyStoreStateCombiner {
  static func custom(_ combineClosure: @escaping StoreStateCombinerClosure<State1, State2, FinalState>) -> AnyStoreStateCombiner<State1, State2, FinalState> {
    CustomStoreStateCombiner(combineClosure: combineClosure).asAnyCombiner()
  }
}

private final class ConcreteStoreStateCombiner<Combiner: StoreStateCombinerProtocol>: BaseStoreStateCombiner<Combiner.State1, Combiner.State2, Combiner.FinalState>, @unchecked Sendable {
  private let combiner: Combiner
  
  init(combiner: Combiner) {
    self.combiner = combiner
  }
  
  override func combineStates(state1: Combiner.State1, state2: Combiner.State2) -> Combiner.FinalState {
    combiner.combineStates(state1: state1, state2: state2)
  }
}

private class BaseStoreStateCombiner<
  State1: StoreStateProtocol,
  State2: StoreStateProtocol,
  FinalState: StoreStateProtocol
>: @unchecked Sendable, StoreStateCombinerProtocol {
  func combineStates(state1: State1, state2: State2) -> FinalState {
    preconditionFailure("Abstract")
  }
}

// MARK: - CustomStoreStateCombiner

private struct CustomStoreStateCombiner<State1: StoreStateProtocol, State2: StoreStateProtocol, FinalState: StoreStateProtocol>: StoreStateCombinerProtocol {
  private let combineClosure: StoreStateCombinerClosure<State1, State2, FinalState>
  
  init(combineClosure: @escaping StoreStateCombinerClosure<State1, State2, FinalState>) {
    self.combineClosure = combineClosure
  }
  
  func combineStates(state1: State1, state2: State2) -> FinalState {
    combineClosure(state1, state2)
  }
}
