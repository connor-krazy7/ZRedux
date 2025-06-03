//
//  ReducerEffectProtocol+Extensions.swift
//  App
//
//  Created by Artsem Hotsau on 22.05.25.
//

import Foundation

public extension ReducerEffectProtocol {
  func asAnyEffect() -> AnyReducerEffect<Action> {
    AnyReducerEffect(effect: self)
  }
}
