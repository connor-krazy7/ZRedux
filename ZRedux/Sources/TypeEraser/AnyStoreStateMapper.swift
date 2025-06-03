//
//  AnyStoreStateMapper.swift
//  App
//
//  Created by Artsem Hotsau on 22.05.25.
//

import Foundation

public final class AnyStoreStateMapper<ParentStoreState: StoreStateProtocol, State: StoreStateProtocol>: StoreStateMapperProtocol {
  private let mapper: BaseStoreStateMapper<ParentStoreState, State>
  
  public init<Mapper: StoreStateMapperProtocol>(mapper: Mapper) where Mapper.ParentStoreState == ParentStoreState, Mapper.State == State {
    self.mapper = ConcreteStoreStateMapper(mapper: mapper)
  }

  public func state(parentState: ParentStoreState) -> State {
    mapper.state(parentState: parentState)
  }
}

private final class ConcreteStoreStateMapper<Mapper: StoreStateMapperProtocol>: BaseStoreStateMapper<Mapper.ParentStoreState, Mapper.State>, @unchecked Sendable {
  private let mapper: Mapper
  
  init(mapper: Mapper) {
    self.mapper = mapper
  }
  
  override func state(parentState: ParentStoreState) -> State {
    mapper.state(parentState: parentState)
  }
}

private class BaseStoreStateMapper<ParentStoreState: StoreStateProtocol, State: StoreStateProtocol>: @unchecked Sendable, StoreStateMapperProtocol {
  func state(parentState: ParentStoreState) -> State {
    preconditionFailure("abstract")
  }
}
