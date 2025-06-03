//
//  ReducerProtocol+Extensions.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public extension ReducerProtocol {
  func asAnyReducer() -> AnyReducer<Action, State> { AnyReducer(reducer: self) }
}
