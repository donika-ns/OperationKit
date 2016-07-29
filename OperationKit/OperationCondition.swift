//
//  OperationCondition.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation


public protocol OperationCondition {
    
    static var name: String { get }
    
//    /**
//     Specifies whether multiple instances of the conditionalized operation may
//     be executing simultaneously.
//     */
    static var isMutuallyExclusive: Bool { get }
    
    func dependencyForOperation(_ operation: Operation) -> Foundation.Operation?
    
    func evaluateForOperation(_ operation: Operation, completion: (OperationConditionResult) -> Void)
}

public enum OperationConditionResult {
    case satisfied
    case failed(NSError)
    
    var error: NSError? {
        if case .failed(let error) = self {
            return error
        }
        
        return nil
    }
}

struct OperationConditionEvaluator {
    
    static func evaluate(_ conditions: [OperationCondition], operation: Operation, completion: ([NSError]) -> Void) {
        // Check conditions
        let conditionGroup = DispatchGroup()
        
        var results = [OperationConditionResult?](repeating: nil, count: conditions.count)
        
        // Ask each condition to evaluate and store its result in the "results" array.
        for (index, condition) in conditions.enumerated() {
            conditionGroup.enter()
            
            condition.evaluateForOperation(operation)  { result in
                results[index] = result
                conditionGroup.leave()
            }
        }
        
        // After all the conditions have evaluated, this block will execute.
        
        let queue = DispatchQueue.global(qos: .default)
        conditionGroup.notify(queue: queue) {
            // Aggregate the errors that occurred, in order.
            var failures: [NSError] = []
            
            for result in results {
                if let fail = result?.error {
                    failures.append(fail)
                }
            }
            
            /*
            If any of the conditions caused this operation to be cancelled,
            check for that.
            */
            if operation.isCancelled {
                failures.append(NSError(code: .conditionFailed))
            }
            
            completion(failures)
        }
    }
}
