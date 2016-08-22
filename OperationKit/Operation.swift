//
//  Operation.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation


/// Abstract: 
open class OKOperation: Operation {
    
    // MARK: - State Management
    
    enum State: Int, Comparable {
        case initialized, pending, evaluatingConditions, ready, executing, finished, cancelled
        
        var keyPath: String {
            switch self {
            case .ready:
                return "isReady"
            case .executing:
                return "isExecuting"
            case .finished:
                return "isFinished"
            case .cancelled:
                return "isCancelled"
            default: return ""
            }
        }
    }
    fileprivate var _state = State.initialized
    fileprivate var state: State {
        get {
            return _state
        }
        
        set(newState) {
            willChangeValue(forKey: _state.keyPath)
            willChangeValue(forKey: newState.keyPath)
            
            switch (_state, newState) {
            case (.cancelled, _):
                break // cannot change state after beeing cancelled
            case (.finished, _):
                break // cannot change state after beeing finished
            default:
                assert(_state != newState, "Trying to apply the same state(\(newState)) again.")
                _state = newState
            }
            
            didChangeValue(forKey: _state.keyPath)
            didChangeValue(forKey: newState.keyPath)
        }
    }
    
    
    // MARK: - Properties
    
    open fileprivate(set) var observers = [OperationObserver]()
    open fileprivate(set) var conditions = [OperationCondition]()
    fileprivate var internalErrors = [NSError]()
    fileprivate var hasFinishedAlready = false
}



// MARK: - Override properties

extension OKOperation {
    
    open override var isReady: Bool {
        switch state {
        case .pending:
            if super.isReady {
                evaluateConditions()
            }
            
            return false
        case .ready:
            return super.isReady
        default: return false
        }
    }
    open override var isExecuting: Bool {
        return state == .executing
    }
    open override var isFinished: Bool {
        return state == .finished
    }
    open override var isCancelled: Bool {
        return state == .cancelled
    }
}



// MARK: - Override functions

extension OKOperation {
    
    public override final func start() {
        assert(state == .ready, "This operation must be performed on an operation queue.")
        
        state = .executing
        
        for obs in observers {
            obs.operationDidStart(self)
        }
        
        execute()
    }
    open func execute() {
        print("\(type(of: self)) must override `main()`.")
        
        finish()
    }
    open override func addDependency(_ op: Operation) {
        assert(state <= .executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(op)
    }
    open override func cancel() {
        cancelWithError()
    }
}


// MARK: - Private API

extension OKOperation {
    
    func willEnqueue() {
        state = .pending
    }
    fileprivate func evaluateConditions() {
        assert(state == .pending, "evaluateConditions() was called out-of-order")
        
        state = .evaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
            if failures.isEmpty {
                // If there were no errors, we may proceed.
                self.state = .ready
            }
            else {
                self.state = .cancelled
                self.finish(failures)
            }
        }
    }
}



// MARK: - Public API

extension OKOperation {
    
    public func addObserver(_ observer: OperationObserver) {
        assert(state < .executing, "Cannot modify after execution has began.")
        
        observers.append(observer)
    }
    public func addCondition(_ condition: OperationCondition) {
        assert(state < .evaluatingConditions, "Cannot modify conditions after execution has begun.")
        
        conditions.append(condition)
    }
    public final func produceOperation(_ operation: Foundation.Operation) {
        for observer in observers {
            observer.operation(self, didProduceOperation: operation)
        }
    }
    public final func cancelWithError(_ error: NSError? = nil) {
        if let error = error {
            internalErrors.append(error)
        }
        
        state = .cancelled
    }
    public final func finishWithError(_ error: NSError?) {
        if let error = error {
            finish([error])
        }
        else {
            finish()
        }
    }
    public final func finish(_ errors: [NSError] = []) {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            
            let combinedErrors = internalErrors + errors
            finished(combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self)
            }
            
            state = .finished
        }
    }
    open func finished(_ errors: [NSError]) {
        
    }
}



// MARK: - Functions for Operation.State Comparable

func <(lhs: OKOperation.State, rhs: OKOperation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
func ==(lhs: OKOperation.State, rhs: OKOperation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
