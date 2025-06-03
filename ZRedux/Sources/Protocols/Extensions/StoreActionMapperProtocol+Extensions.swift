//
//  StoreActionMapperProtocol+Extensions.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public extension StoreActionMapperProtocol {
  func asAnyMapper() -> AnyStoreActionMapper<Action, ParentStoreAction> {
    AnyStoreActionMapper(actionMapper: self)
  }
}
