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
    
    func dependencyForOperation(operation: Operation) -> NSOperation?
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void)
}

public enum OperationConditionResult {
    case Satisfied
    case Failed(NSError)
    
    var error: NSError? {
        if case .Failed(let error) = self {
            return error
        }
        
        return nil
    }
}

struct OperationConditionEvaluator {
    
    static func evaluate(conditions: [OperationCondition], operation: Operation, completion: [NSError] -> Void) {
        // Check conditions
        let conditionGroup = dispatch_group_create()
        
        var results = [OperationConditionResult?](count: conditions.count, repeatedValue: nil)
        
        // Ask each condition to evaluate and store its result in the "results" array.
        for (index, condition) in conditions.enumerate() {
            dispatch_group_enter(conditionGroup)
            
            condition.evaluateForOperation(operation)  { result in
                results[index] = result
                dispatch_group_leave(conditionGroup)
            }
        }
        
        // After all the conditions have evaluated, this block will execute.
        dispatch_group_notify(conditionGroup, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
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
            if operation.cancelled {
                failures.append(NSError(code: .ConditionFailed))
            }
            
            completion(failures)
        }
    }
}
