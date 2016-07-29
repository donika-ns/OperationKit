//
//  MutuallyExclusive.swift
//  OperationKit
//
//  Created by SiSo Mollov on 3/4/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation

/// A generic condition for describing kinds of operations that may not execute concurrently.
public struct MutuallyExclusive<T>: OperationCondition {
    public static var name: String {
        return "MutuallyExclusive<\(T.self)>"
    }
    
    public static var isMutuallyExclusive: Bool {
        return true
    }
    
    init() { }
    
    public func dependencyForOperation(_ operation: Operation) -> Foundation.Operation? {
        return nil
    }
    
    public func evaluateForOperation(_ operation: Operation, completion: (OperationConditionResult) -> Void) {
        completion(.satisfied)
    }
}

/**
 The purpose of this enum is to simply provide a non-constructible
 type to be used with `MutuallyExclusive<T>`.
 */
enum Alert { }

/// A condition describing that the targeted operation may present an alert.
typealias AlertPresentation = MutuallyExclusive<Alert>
