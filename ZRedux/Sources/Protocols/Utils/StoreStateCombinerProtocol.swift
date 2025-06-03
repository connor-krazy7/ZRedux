//
//  StoreStateCombinerProtocol.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public protocol StoreStateCombinerProtocol: Sendable {
  associatedtype State1: StoreStateProtocol
  associatedtype State2: StoreStateProtocol
  associatedtype FinalState: StoreStateProtocol
  
  func combineStates(state1: State1, state2: State2) -> FinalState
}

public typealias StoreStateCombinerClosure<
  State1: StoreStateProtocol,
  State2: StoreStateProtocol,
  FinalState: StoreStateProtocol,
> = @Sendable (_ state1: State1, _ state2: State2) -> sending FinalState
