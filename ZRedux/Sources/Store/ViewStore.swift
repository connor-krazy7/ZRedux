//
//  ViewStore.swift
//  App
//
//  Created by Artsem Hotsau on 22.05.25.
//

#if canImport(SwiftUI)
import Foundation
import SwiftUI

public enum ViewStoreState<State: Sendable>: Sendable {
  case loading
  case loaded(State)
}

@MainActor
@Observable
public final class ViewStore<State: StoreStateProtocol, Action> {
  private let parentStore: AnyStore<State, Action>
  @ObservationIgnored
  private var dataTask: Task<Void, Error>?
  
  public var state: ViewStoreState<State> = .loading
  
  public var loadedState: State? {
    guard case let .loaded(state) = state else { return nil }
    return state
  }
  
  nonisolated public init<ParentStore: StoreProtocol>(
    parentStore: ParentStore
  ) where ParentStore: AnyObject, ParentStore.State == State, ParentStore.Action == Action {
    self.parentStore = AnyStore(store: parentStore)
    Task { @MainActor in
      self.state = await .loaded(parentStore.state)
      self.dataTask = await self.createDataTask(storeUpdatesStream: parentStore.storeUpdatesStream)
    }
  }
  
  public init<ParentStore: StoreProtocol>(
    parentStore: ParentStore
  ) async where ParentStore: AnyObject, ParentStore.State == State, ParentStore.Action == Action {
    self.parentStore = AnyStore(store: parentStore)
    self.state = await .loaded(parentStore.state)
    self.dataTask = await createDataTask(storeUpdatesStream: parentStore.storeUpdatesStream)
  }
  
  private func createDataTask(storeUpdatesStream: AsyncStream<StoreUpdate<State>>) -> Task<Void, Error> {
    Task { [weak self] in
      try Task.checkCancellation()
      
      for await storeUpdate in storeUpdatesStream {
        try Task.checkCancellation()
        self?.state = .loaded(storeUpdate.state)
      }
    }
  }
  
  public nonisolated func postAction(_ action: sending Action) async {
    await parentStore.postAction(action)
  }
}
#endif
