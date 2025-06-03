//
//  StoreStateCombinerProtocol+Extensions.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public extension StoreStateCombinerProtocol {
  func asAnyCombiner() -> AnyStoreStateCombiner<State1, State2, FinalState> {
    AnyStoreStateCombiner(combiner: self)
  }
}
