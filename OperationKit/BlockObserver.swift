//
//  BlockObserver.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation

/**
 *  The `BlockObserver` is way to attach blocks to `Operation` events.
 */
public struct BlockObserver {
    
    private let startHandler: (Operation -> Void)?
    private let produceHandler: ((operation: Operation, newOperation: NSOperation) -> Void)?
    private let finishHandler: ((operation: Operation) -> Void)?
    
    public init(startHandler: (Operation -> Void)? = nil, produceHandler: ((Operation, NSOperation) -> Void)? = nil, finishHandler: ((operation: Operation) -> Void)? = nil) {
        
        self.startHandler   = startHandler
        self.produceHandler = produceHandler
        self.finishHandler  = finishHandler
    }
}


// MARK: - OperationObserver

extension BlockObserver: OperationObserver {
    
    public func operationDidStart(operation: Operation) {
        startHandler?(operation)
    }
    public func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation: operation, newOperation: newOperation)
    }
    public func operationDidFinish(operation: Operation) {
        finishHandler?(operation: operation)
    }
}
