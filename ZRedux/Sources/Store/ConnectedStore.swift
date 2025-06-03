//
//  ConnectedStore.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

public final class ConnectedStore<State: StoreStateProtocol, Action>: StoreProtocol {
  private let substore: AnyStore<State, Action>
  private let connector: AnyStoreConnector<State, Action>
  private let storeUpdatesObserver: StoreUpdatesObserver
  
  public var storeUpdatesStream: StoreUpdatesStream { get async { await storeUpdatesObserver.values() } }
  public var state: State { get async { await substore.state } }
  
  init<Substore, Connector>(
    substore: Substore,
    connector: Connector
  ) where Substore: StoreProtocol, Substore.State == State, Substore.Action == Action, Connector: StoreConnectorProtocol, Connector.State == State, Connector.Action == Action {
    self.substore = AnyStore(store: substore)
    self.connector = AnyStoreConnector(connector: connector)
    self.storeUpdatesObserver = Self.makeUpdatesObserver()
  }
  
  private func attachConnector() async {
    guard await !connector.isConnected else { return }
    await connector.connect(to: self)
  }
  
  public func postAction(_ action: sending Action) async {
    await attachConnector()
    await substore.postAction(action)
  }
}
