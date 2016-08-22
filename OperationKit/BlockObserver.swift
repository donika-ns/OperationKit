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
    
    fileprivate let startHandler: ((Operation) -> Void)?
    fileprivate let produceHandler: ((_ operation: Operation, _ newOperation: Foundation.Operation) -> Void)?
    fileprivate let finishHandler: ((_ operation: Operation) -> Void)?
    
    public init(startHandler: ((Operation) -> Void)? = nil, produceHandler: ((Operation, Foundation.Operation) -> Void)? = nil, finishHandler: ((_ operation: Operation) -> Void)? = nil) {
        
        self.startHandler   = startHandler
        self.produceHandler = produceHandler
        self.finishHandler  = finishHandler
    }
}


// MARK: - OperationObserver

extension BlockObserver: OperationObserver {
    
    public func operationDidStart(_ operation: Operation) {
        startHandler?(operation)
    }
    public func operation(_ operation: Operation, didProduceOperation newOperation: Foundation.Operation) {
        produceHandler?(operation, newOperation)
    }
    public func operationDidFinish(_ operation: Operation) {
        finishHandler?(operation)
    }
}
