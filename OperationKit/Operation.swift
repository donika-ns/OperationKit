//
//  Operation.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation


/// Abstract: 
public class Operation: NSOperation {
    
    // MARK: - State Management
    
    enum State: Int, Comparable {
        case Initialized, Pending, EvaluatingConditions, Ready, Executing, Finished, Cancelled
        
        var keyPath: String {
            switch self {
            case .Ready:
                return "isReady"
            case .Executing:
                return "isExecuting"
            case .Finished:
                return "isFinished"
            case .Cancelled:
                return "isCancelled"
            default: return ""
            }
        }
    }
    private var _state = State.Initialized
    private var state: State {
        get {
            return _state
        }
        
        set(newState) {
            willChangeValueForKey(_state.keyPath)
            willChangeValueForKey(newState.keyPath)
            
            switch (_state, newState) {
            case (.Cancelled, _):
                break // cannot change state after beeing cancelled
            case (.Finished, _):
                break // cannot change state after beeing finished
            default:
                assert(_state != newState, "Trying to apply the same state(\(newState)) again.")
                _state = newState
            }
            
            didChangeValueForKey(_state.keyPath)
            didChangeValueForKey(newState.keyPath)
        }
    }
    
    
    // MARK: - Properties
    
    public private(set) var observers = [OperationObserver]()
    public private(set) var conditions = [OperationCondition]()
    private var internalErrors = [NSError]()
    private var hasFinishedAlready = false
}



// MARK: - Override properties

extension Operation {
    
    public override var ready: Bool {
        switch state {
        case .Pending:
            if super.ready {
                evaluateConditions()
            }
            
            return false
        case .Ready:
            return super.ready
        default: return false
        }
    }
    public override var executing: Bool {
        return state == .Executing
    }
    public override var finished: Bool {
        return state == .Finished
    }
    public override var cancelled: Bool {
        return state == .Cancelled
    }
}



// MARK: - Override functions

extension Operation {
    
    public override final func start() {
        assert(state == .Ready, "This operation must be performed on an operation queue.")
        
        state = .Executing
        
        for obs in observers {
            obs.operationDidStart(self)
        }
        
        execute()
    }
    public func execute() {
        print("\(self.dynamicType) must override `main()`.")
        
        finish()
    }
    public override func addDependency(op: NSOperation) {
        assert(state <= .Executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(op)
    }
    public override func cancel() {
        cancelWithError()
    }
}


// MARK: - Private API

extension Operation {
    
    func willEnqueue() {
        state = .Pending
    }
    private func evaluateConditions() {
        assert(state == .Pending, "evaluateConditions() was called out-of-order")
        
        state = .EvaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
            if failures.isEmpty {
                // If there were no errors, we may proceed.
                self.state = .Ready
            }
            else {
                self.state = .Cancelled
                self.finish(failures)
            }
        }
    }
}



// MARK: - Public API

extension Operation {
    
    public func addObserver(observer: OperationObserver) {
        assert(state < .Executing, "Cannot modify after execution has began.")
        
        observers.append(observer)
    }
    public func addCondition(condition: OperationCondition) {
        assert(state < .EvaluatingConditions, "Cannot modify conditions after execution has begun.")
        
        conditions.append(condition)
    }
    public final func produceOperation(operation: NSOperation) {
        
    }
    public final func cancelWithError(error: NSError? = nil) {
        if let error = error {
            internalErrors.append(error)
        }
        
        state = .Cancelled
    }
    public final func finishWithError(error: NSError?) {
        if let error = error {
            finish([error])
        }
        else {
            finish()
        }
    }
    public final func finish(errors: [NSError] = []) {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            
            let combinedErrors = internalErrors + errors
            finished(combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self)
            }
            
            state = .Finished
        }
    }
    public func finished(errors: [NSError]) {
        
    }
}



// MARK: - Functions for Operation.State Comparable

func <(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
func ==(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
