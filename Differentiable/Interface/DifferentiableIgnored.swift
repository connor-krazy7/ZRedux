//
//  DataModel.swift
//  
//
//  Created by Artsem Hotsau on 21.05.25.
//

/// Explicitly exclude property from auto generated conformance created by macro <doc:Differentiable()>
///
/// Example:
///
/// **Model**
/// ```
/// @Differentiable
/// struct DataModel {
///   @DifferentiableIgnored
///   let int_prop: Int
///   let string_prop: String
/// }
/// ```
/// **GeneratedCode**
/// ```
/// extension DataModel: DifferentiableProtocol {
///   typealias DifferentiableKeyPath = PartialKeyPath<Self>
///
///   func difference(from state: Self) -> Set<DifferentiableKeyPath> {
///     var differences: Set<DifferentiableKeyPath> = []
///
///     if string_prop != state.string_prop {
///       differences.insert(\.string_prop)
///     }
///
///     return differences
///   }
///
///   static var allDifferentialKeyPaths: Set<DifferentiableKeyPath> {
///     [
///       \.string_prop
///     ]
///   }
/// }
/// ```
/// > Hint: Highly usefull when macro <doc:Differentiable()> is used with an object containing non `Equatable` properties
@attached(peer)
public macro DifferentiableIgnored() = #externalMacro(module: "DifferentiableMacros", type: "DifferentiableIgnoredMacro")
