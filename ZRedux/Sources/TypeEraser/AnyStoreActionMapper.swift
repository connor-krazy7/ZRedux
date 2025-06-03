//
//  AnyStoreActionMapper.swift
//  App
//
//  Created by Artsem Hotsau on 22.05.25.
//

import Foundation

public final class AnyStoreActionMapper<Action, ParentStoreAction>: StoreActionMapperProtocol {
  private let actionMapper: BaseStoreActionMapper<Action, ParentStoreAction>
  
  public init<ActionMapper: StoreActionMapperProtocol>(actionMapper: ActionMapper) where ActionMapper.Action == Action, ActionMapper.ParentStoreAction == ParentStoreAction {
    self.actionMapper = ConcreteStoreActionMapper(actionMapper: actionMapper)
  }

  public func parentAction(_ action: Action) -> ParentStoreAction {
    actionMapper.parentAction(action)
  }
}

public extension AnyStoreActionMapper {
  static func custom(_ mapAction: @escaping StoreActionMapperClosure<Action, ParentStoreAction>) -> AnyStoreActionMapper<Action, ParentStoreAction> {
    CustomStoreActionMapper(mapAction: mapAction).asAnyMapper()
  }
}

private final class ConcreteStoreActionMapper<ActionMapper: StoreActionMapperProtocol>: BaseStoreActionMapper<ActionMapper.Action, ActionMapper.ParentStoreAction>, @unchecked Sendable {
  private let actionMapper: ActionMapper
  
  init(actionMapper: ActionMapper) {
    self.actionMapper = actionMapper
  }
  
  override func parentAction(_ action: Action) -> ParentStoreAction {
    actionMapper.parentAction(action)
  }
}

private class BaseStoreActionMapper<Action, ParentStoreAction>: @unchecked Sendable, StoreActionMapperProtocol {
  func parentAction(_ action: Action) -> ParentStoreAction {
    preconditionFailure("abstract")
  }
}

// MARK: - CustomStoreActionMapper

public struct CustomStoreActionMapper<Action, ParentStoreAction>: @unchecked Sendable, StoreActionMapperProtocol {
  private let mapAction: StoreActionMapperClosure<Action, ParentStoreAction>
  
  public init(mapAction: @escaping StoreActionMapperClosure<Action, ParentStoreAction>) {
    self.mapAction = mapAction
  }
  
  public func parentAction(_ action: Action) -> ParentStoreAction { mapAction(action) }
}
