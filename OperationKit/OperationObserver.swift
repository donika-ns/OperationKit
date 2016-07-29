//
//  OperationObserver.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation

// Abstract:
// This file defines the OperationObserver protocol.

public protocol OperationObserver {
    
    /**
     Invoced immidately before the Operation performs execute() method.
     
     - parameter operation: current Operation
     */
    func operationDidStart(_ operation: Operation)
    
    /**
     Invoced when Operation.produceOperation is executed.
     
     - parameter operation:    current Operation
     - parameter newOperation: newOperation that `operation` produce.
     */
    func operation(_ operation: Operation, didProduceOperation newOperation: Foundation.Operation)
    
    /**
     Invoce as an Operation finishes
     
     - parameter operation: current Operation
     */
    func operationDidFinish(_ operation: Operation)
}
