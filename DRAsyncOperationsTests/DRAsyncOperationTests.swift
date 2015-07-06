//
//  DRAsyncOperationSwiftTests.swift
//  DRAsyncOperations
//
//  Created by David Rodrigues on 20/04/15.
//  Copyright (c) 2015 David Rodrigues. All rights reserved.
//

import Foundation
import XCTest

class DRAsyncOperationSwiftTests: XCTestCase {

    var queue: NSOperationQueue!
    
    override func setUp() {
        super.setUp()

        queue = NSOperationQueue()
    }

    func testSimpleAsyncBlockOperation() {
        
        let expectation = self.expectationWithDescription("DRAsyncBlockOperation completed")
        
        queue.addOperation({
            
            let asyncOperation = DRAsyncBlockOperation { (finishBlock) -> Void in
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    NSThread.sleepForTimeInterval(0.5)
                    
                    finishBlock()
                }
            }
            
            asyncOperation.completionBlock = {
                expectation.fulfill()
            }
            
            return asyncOperation;
        }())
        
        self.waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error)
        })
    }
    
    func testAsyncBlockOperationCancellation() {
        
        let expectation = self.expectationWithDescription("DRAsyncBlockOperation completed")
        
        var asyncOperation: DRAsyncBlockOperation!
        
        asyncOperation = DRAsyncBlockOperation { (finishBlock) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                NSThread.sleepForTimeInterval(2.0)
                
                if asyncOperation.cancelled {
                    finishBlock()
                    return;
                }
                
                NSThread.sleepForTimeInterval(2.0)
                
                finishBlock()
            }
        }
        
        asyncOperation.completionBlock = {
            expectation.fulfill()
        }
        
        queue.addOperation(asyncOperation)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            asyncOperation.cancel()
        });
        
        self.waitForExpectationsWithTimeout(3.0, handler: { (error) -> Void in
            XCTAssertNil(error)
        })
    }
    
    func testAsyncOperationSubclass() {
        
        // Implement an async operation subclass
        class RandomAsyncOperation: DRAsyncOperation {
            
            var completed = false
            
            private override func asyncTask() {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    NSThread.sleepForTimeInterval(0.5)
                    
                    self.completed = true
                    
                    self.finish()
                }
            }
        }
        
        let expectation = self.expectationWithDescription("DRAsyncOperation subclass completed")
        
        let operation = RandomAsyncOperation()
        
        operation.completionBlock = {
            expectation.fulfill()
        }
        
        // Note that this call will not block until the operation has finished
        operation.start()
        
        XCTAssertTrue(operation.executing)
        XCTAssertFalse(operation.finished)
        
        self.waitForExpectationsWithTimeout(2.0, handler: { (error) -> Void in
            XCTAssertNil(error)
            XCTAssertTrue(operation.completed)
            XCTAssertTrue(operation.finished)
        })
    }
    
}
