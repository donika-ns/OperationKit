//
//  OperationQueue.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation


public class OperationQueue: NSOperationQueue {
    
    public override func addOperation(op: NSOperation) {
        if let op = op as? Operation {
            
            // Extract any dependencies needed by this operation.
            var dependencies: [NSOperation] = []
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
                Indicate to the operation that we've finished our extra work on it
                and it's now it a state where it can proceed with evaluating conditions,
                if appropriate.
            */
            op.willEnqueue()
        }
        
        super.addOperation(op)
    }
    
    public override func addOperations(ops: [NSOperation], waitUntilFinished wait: Bool) {
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
