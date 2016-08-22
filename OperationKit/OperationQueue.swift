//
//  OperationQueue.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation


open class OKOperationQueue: OperationQueue {
    
    
    
    open override func addOperation(_ op: Operation) {
        if let op = op as? OKOperation {
            
            let delegate = BlockObserver(
                startHandler: nil,
                produceHandler: { [weak self] in
                    self?.addOperation($1)
                },
                finishHandler: nil
            )
            op.addObserver(delegate)
            
            // Extract any dependencies needed by this operation.
            var dependencies: [Operation] = []
            for condition in op.conditions {
                if let dependency = condition.dependencyForOperation(op) {
                    dependencies.append(dependency)
                }
            }
            
            for dependency in dependencies {
                op.addDependency(dependency)
                
                self.addOperation(dependency)
            }
            
            /*
                With condition dependencies added, we can now see if this needs
                dependencies to enforce mutual exclusivity.
            */

            let concurrencyCategories: [String] = op.conditions.flatMap { condition in
                if !type(of: condition).isMutuallyExclusive { return nil }
                
                return "\(type(of: condition))"
            }
            
            if !concurrencyCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.sharedExclusivityController
                
                exclusivityController.addOperation(op, categories: concurrencyCategories)
                
                op.addObserver(BlockObserver { operation in
                    exclusivityController.removeOperation(operation, categories: concurrencyCategories)
                })
            }
            
            /*
                Indicate to the operation that we've finished our extra work on it
                and it's now it a state where it can proceed with evaluating conditions,
                if appropriate.
            */
            op.willEnqueue()
        }
        
        super.addOperation(op)
    }
    
    open override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        /*
            The base implementation of this method does not call `addOperation()`,
            so we'll call it ourselves.
        */
        for operation in ops {
            addOperation(operation)
        }
        
        if wait {
            for operation in ops {
                operation.waitUntilFinished()
            }
        }
    }
}
