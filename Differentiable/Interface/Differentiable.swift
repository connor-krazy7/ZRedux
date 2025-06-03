//
//  Differentiable.swift
//
//
//  Created by Artsem Hotsau on 21.05.25.
//

/// Generate automatic conformance to `DifferentiableProtocol`
///
/// Example:
///
/// **Model**
/// ```
/// @Differentiable
/// struct DataModel {
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
///     if int_prop != state.int_prop {
///       differences.insert(\.int_prop)
///     }
///     if string_prop != state.string_prop {
///       differences.insert(\.string_prop)
///     }
///
///     return differences
///   }
///
///   static var allDifferentialKeyPaths: Set<DifferentiableKeyPath> {
///     [
///       \.int_prop,
///       \.string_prop
///     ]
///   }
/// }
/// ```
/// > Hint: If you need to explicitly exclude property from auto generated conformance see macro <doc:DifferentiableIgnored()>
///
/// > WARNING: Macro takes into account only stored instance properties, that is said: computed, async, throws or static properties are implicitly ignored
///
@attached(extension, conformances: DifferentiableProtocol, names: named(DifferentiableKeyPath), named(difference), named(allDifferentialKeyPaths))
public macro Differentiable() = #externalMacro(module: "DifferentiableMacros", type: "DifferentiableMacro")
