//
//  StoreProtocol.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public protocol StoreProtocol: StoreConstraintsProtocol, StoreActionDispatcherProtocol {
  typealias StoreUpdatesStream = AsyncStream<StoreUpdate<State>>
  
  var storeUpdatesStream: StoreUpdatesStream { get async }
  var state: State { get async }
}

public protocol StoreActionDispatcherProtocol: Sendable, AnyObject {
  associatedtype Action
  
  func postAction(_ action: sending Action) async
}

public protocol StoreConstraintsProtocol {
  associatedtype State: StoreStateProtocol
}
