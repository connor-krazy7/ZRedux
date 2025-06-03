//
//  StoreStateMapperProtocol.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public protocol StoreStateMapperProtocol: Sendable {
  associatedtype ParentStoreState: StoreStateProtocol
  associatedtype State: StoreStateProtocol
  
  func state(parentState: ParentStoreState) -> State
}

public typealias StoreStateMapperClosure<ParentStoreState: StoreStateProtocol, State: StoreStateProtocol> = @Sendable (_ action: ParentStoreState) -> State

public struct CustomStoreStateMapper<ParentStoreState: StoreStateProtocol, State: StoreStateProtocol>: StoreStateMapperProtocol {
  private let mapState: StoreStateMapperClosure<ParentStoreState, State>
  
  public init(mapState: @escaping StoreStateMapperClosure<ParentStoreState, State>) {
    self.mapState = mapState
  }
  
  public func state(parentState: ParentStoreState) -> State {
    mapState(parentState)
  }
}
