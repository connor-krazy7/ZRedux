//
//  Playground.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 3.06.25.
//

import ZRedux
import Differentiable

@main
struct Playground {
  struct SubstoreState: StoreStateProtocol {
    var int: Int = 0
    var string: String = ""
  }
  
  struct StoreState: StoreStateProtocol {
    var substoreState = SubstoreState()
    var double: Double = 0
  }
  
  enum StoreAction {
    case enter
  }
  
  enum EnrichedAction {
    case enrichedEnter(int: Int)
  }
  
  enum ErasedStoreAction {
    case erasedEnter
  }
  
  final class StoreReducer: ReducerProtocol {
    typealias Action = StoreAction
    typealias State = StoreState
    
    func reduce(state: inout State, action: sending Action) -> sending AnyReducerEffect<Action> { .noEffect }
  }
  
  static func main() async throws {
    let store: AnyStore<SubstoreState, ErasedStoreAction> = Store(
      state: StoreState(),
      reducer: StoreReducer(),
      effectExecutor: .detachedTaskExecutor
    )
      .scopeState(\.substoreState)
      .eraseActionType(to: EnrichedAction.self, mapErasedAction: { _ in .enter })
      .enrichAction(ErasedStoreAction.self) { .enrichedEnter(int: $1.int) }
      .asAnyStore()
    let _ = await store.state.int
    let _ = await store.state.string
    print(#function)
  }
}

extension Int: StoreStateProtocol { }
extension String: StoreStateProtocol { }
extension Double: StoreStateProtocol { }

public extension StoreStateProtocol {
  typealias DifferentiableKeyPath = PartialKeyPath<Self>
  
  func difference(from state: Self) -> sending Set<PartialKeyPath<Self>> { [] }
}
