//
//  StoreActionMapperProtocol.swift
//  App
//
//  Created by Artsem Hotsau on 21.05.25.
//

import Foundation

public protocol StoreActionMapperProtocol: Sendable {
  associatedtype Action
  associatedtype ParentStoreAction
  
  func parentAction(_ action: Action) -> ParentStoreAction
}

public typealias StoreActionMapperClosure<Action, ParentStoreAction> = @Sendable (_ action: Action) -> ParentStoreAction
