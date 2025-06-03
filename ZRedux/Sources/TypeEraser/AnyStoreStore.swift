//
//  AnyStoreStore.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public final class AnyStoreConnector<State: StoreStateProtocol, Action>: StoreConnectorProtocol {
  private let connector: BaseStoreConnector<State, Action>
  
  public var isConnected: Bool { get async { await connector.isConnected } }
  
  init<Connector>(connector: Connector) where Connector: StoreConnectorProtocol, Connector.State == State, Connector.Action == Action {
    self.connector = ConcreteStoreConnector(connector: connector)
  }
  
  public func connect<Store>(to store: Store) async where Store : StoreProtocol, Action == Store.Action, State == Store.State {
    await connector.connect(to: store)
  }
}

private final class ConcreteStoreConnector<Connector: StoreConnectorProtocol>: BaseStoreConnector<Connector.State, Connector.Action>, @unchecked Sendable {
  private let connector: Connector
  
  init(connector: Connector) {
    self.connector = connector
  }
  
  override var isConnected: Bool { get async { await connector.isConnected } }
  
  override func connect<Store>(to store: Store) async where Connector.State == Store.State, Connector.Action == Store.Action, Store : StoreProtocol {
    await connector.connect(to: store)
  }
}

private class BaseStoreConnector<State: StoreStateProtocol, Action>: @unchecked Sendable, StoreConnectorProtocol {
  var isConnected: Bool { get async { preconditionFailure("Abstract") } }
  
  func connect<Store>(to store: Store) async where Store : StoreProtocol, Action == Store.Action, State == Store.State {
    preconditionFailure("Abstract")
  }
}
