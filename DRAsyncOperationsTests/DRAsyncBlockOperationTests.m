//
//  DRAsyncBlockOperationTests.m
//  DRAsyncOperations
//
//  Created by David Rodrigues on 26/04/15.
//  Copyright (c) 2015 David Rodrigues. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

#import "DRAsyncBlockOperation.h"
#import "DRAsyncOperationSubclass.h"

@interface DRAsyncBlockOperationTests : XCTestCase

@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation DRAsyncBlockOperationTests

- (void)setUp {
    [super setUp];
    
    self.queue = [[NSOperationQueue alloc] init];
}

- (void)testScheduleSimpleAsyncOperation {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async Operation Completed"];
    
    DRAsyncBlockOperation *asyncOperation = [DRAsyncBlockOperation asyncBlockOperationWithBlock:^(DRAsyncBlockOperationFinishBlock finishBlock) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [NSThread sleepForTimeInterval:2.0];
            
            finishBlock();
        });

    }];
    
    asyncOperation.completionBlock = ^{
        [expectation fulfill];
    };
    
    [self.queue addOperation:asyncOperation];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testScheduleSimpleAsyncOperationWithDependencies {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async Operation Completed"];
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        [NSThread sleepForTimeInterval:1.0];
    }];
    
    DRAsyncBlockOperation *asyncOperation = [DRAsyncBlockOperation asyncBlockOperationWithBlock:^(DRAsyncBlockOperationFinishBlock finishBlock) {
        
        XCTAssertTrue([blockOperation isFinished]);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [NSThread sleepForTimeInterval:2.0];
            
            finishBlock();
        });
    }];
    
    asyncOperation.completionBlock = ^{
        [expectation fulfill];
    };
    
    [asyncOperation addDependency:blockOperation];
    
    [self.queue addOperations:@[blockOperation, asyncOperation] waitUntilFinished:NO];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testStartOperationAlreadyFinished
{
    DRAsyncBlockOperation *asyncOperation = [DRAsyncBlockOperation asyncBlockOperationWithBlock:^(DRAsyncBlockOperationFinishBlock finishBlock) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [NSThread sleepForTimeInterval:1.0];
            
            finishBlock();
        });
    }];
    
    [asyncOperation start];
    [asyncOperation waitUntilFinished];
    
    XCTAssertTrue([asyncOperation isFinished], @"operation should be finished");
    
    [asyncOperation start];
    
    XCTAssertTrue([asyncOperation isFinished], @"operation should be already finished");
}

- (void)testStartOperationAlreadyCancelled
{
    DRAsyncBlockOperation *asyncOperation = [DRAsyncBlockOperation asyncBlockOperationWithBlock:^(DRAsyncBlockOperationFinishBlock finishBlock) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [NSThread sleepForTimeInterval:10.0];
            
            finishBlock();
        });
    }];
    
    [asyncOperation cancel];
    
    XCTAssertTrue([asyncOperation isCancelled], @"operation should be cancelled");
    
    [asyncOperation start];
    
    XCTAssertFalse([asyncOperation isExecuting], @"operation should not be finished");
    XCTAssertTrue([asyncOperation isCancelled], @"operation should be cancelled");
    XCTAssertTrue([asyncOperation isFinished], @"operation should be finished");
}

- (void)testCancelOfLongRunningOperation
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async Operation Completed"];
    
    __block DRAsyncBlockOperation *asyncOperation = [DRAsyncBlockOperation asyncBlockOperationWithBlock:^(DRAsyncBlockOperationFinishBlock finishBlock) {
        
        [NSThread sleepForTimeInterval:10.0];
        
        if ([asyncOperation isCancelled]) {
            finishBlock();
            return;
        }
        
        [NSThread sleepForTimeInterval:10.0];
        
        if ([asyncOperation isCancelled]) {
            finishBlock();
            return;
        }
        
        [NSThread sleepForTimeInterval:10.0];
        
        finishBlock();
    }];
    
    asyncOperation.completionBlock = ^{
        [expectation fulfill];
    };
    
    [self.queue addOperation:asyncOperation];
    
    // Cancel operation 5 seconds after start executing
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [asyncOperation cancel];
    });
    
    // The operation, if not cancelled, will take 30 seconds to execute. We will cancel it 5 seconds after
    // start and it will acknowledge cancellation after 10 seconds, finishing right after that.
    [self waitForExpectationsWithTimeout:12.0 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testAyncBlockOperationWithoutExecutionBlock {
#if DEBUG
    XCTAssertThrows([DRAsyncBlockOperation asyncBlockOperationWithBlock:nil]);
#else
    XCTAssertNil([DRAsyncBlockOperation asyncBlockOperationWithBlock:nil]);
#endif
}

@end
