//
//  OperationErrors.swift
//  OperationKit
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import Foundation

let OperationErrorDomain = "OperationErrors"

public enum OperationErrorCode: Int {
    case conditionFailed = 1
    case executionFailed
}

public extension NSError {
    convenience init(code: OperationErrorCode, userInfo: [NSObject: AnyObject]? = nil) {
        self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}
