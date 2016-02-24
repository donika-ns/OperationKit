//
//  OperationKitTests.swift
//  OperationKitTests
//
//  Created by SiSo Mollov on 2/23/16.
//  Copyright © 2016 SiSo Mollov. All rights reserved.
//

import XCTest
import OperationKit


class CustomOperation: Operation {
    override func main() {
        print("Tralala")
        
        finish()
    }
}

class OperationKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let queue = NSOperationQueue()
        let op1 = CustomOperation()
        
        queue.addOperation(op1)
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
