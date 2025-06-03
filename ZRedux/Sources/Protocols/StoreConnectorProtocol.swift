//
//  StoreConnectorProtocol.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public protocol StoreConnectorProtocol: Sendable {
  associatedtype State: StoreStateProtocol
  associatedtype Action
  
  var isConnected: Bool { get async }
  
  func connect<Store>(to store: Store) async where Store: StoreProtocol, Store.Action == Action, Store.State == State
}
