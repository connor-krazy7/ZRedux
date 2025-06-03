//
//  DifferentiableProtocol.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 2.06.25.
//

import Foundation

public protocol DifferentiableProtocol {
  associatedtype DifferentiableKeyPath: Hashable
  
  func difference(from state: Self) -> sending Set<DifferentiableKeyPath>
}
