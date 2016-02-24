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
    func operationDidStart(operation: Operation)
    
    /**
     Invoced when Operation.produceOperation is executed.
     
     - parameter operation:    current Operation
     - parameter newOperation: newOperation that `operation` produce.
     */
    func operation(operation: Operation, didProduceOperation newOperation: Operation)
    
    /**
     Invoce as an Operation finishes
     
     - parameter operation: current Operation
     */
    func operationDidFinish(operation: Operation)
}
