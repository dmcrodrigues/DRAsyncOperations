//
//  DRAsyncOperation.m
//  DRAsyncOperations
//
//  Created by David Rodrigues on 17/04/15.
//  Copyright (c) 2015 David Rodrigues. All rights reserved.
//

#import "DRAsyncOperation.h"

typedef NS_ENUM(char, DRAsyncOperationState) {
    DRAsyncOperationStateReady,
    DRAsyncOperationStateExecuting,
    DRAsyncOperationStateFinished
};

static inline NSString *DRKeyPathFromAsyncOperationState(DRAsyncOperationState state) {
    switch (state) {
        case DRAsyncOperationStateReady:        return @"isReady";
        case DRAsyncOperationStateExecuting:    return @"isExecuting";
        case DRAsyncOperationStateFinished:     return @"isFinished";
    }
}

@interface DRAsyncOperation ()

@property(nonatomic, assign) DRAsyncOperationState state;

@end

@implementation DRAsyncOperation

#pragma mark - 
#pragma mark NSOperation methods

#if defined(__IPHONE_OS_VERSION_MIN_ALLOWED) && __IPHONE_OS_VERSION_MIN_ALLOWED >= __IPHONE_7_0
- (BOOL)isAsynchronous
{
    return YES;
}
#endif

#if defined(__IPHONE_OS_VERSION_MIN_ALLOWED) && __IPHONE_OS_VERSION_MIN_ALLOWED < __IPHONE_7_0
- (BOOL)isConcurrent
{
    return YES;
}
#endif

- (BOOL)isExecuting
{
    @synchronized(self) {
        return self.state == DRAsyncOperationStateExecuting;
    }
}

- (BOOL)isFinished
{
    @synchronized(self) {
        return self.state == DRAsyncOperationStateFinished;
    }
}

- (void)start
{
    @autoreleasepool {
        
        if ([self isCancelled]) {
            [self finish];
            return;
        }
        
        @synchronized(self) {
            
            // Ignore this call if the operation is already executing or if has finished already
            if (self.state != DRAsyncOperationStateReady) {
                return;
            }
            
            // Signal the beginning of operation
            self.state = DRAsyncOperationStateExecuting;
        }
        
        // Execute async task
        [self asyncTask];
    }
}

#pragma mark -
#pragma mark DRAsyncOperation methods

- (void)setState:(DRAsyncOperationState)state
{
    @synchronized(self) {
        
        NSString *oldStateKey = DRKeyPathFromAsyncOperationState(_state);
        NSString *newStateKey = DRKeyPathFromAsyncOperationState(state);
        
        [self willChangeValueForKey:oldStateKey];
        [self willChangeValueForKey:newStateKey];
        
        _state = state;
        
        [self didChangeValueForKey:newStateKey];
        [self didChangeValueForKey:oldStateKey];
    }
}

#pragma mark Protected methods

- (void)asyncTask
{
    [self finish];
}

- (void)finish
{
    @synchronized(self) {
        
        // Ignore this call if the operation has finished
        if (self.state == DRAsyncOperationStateFinished) {
            return;
        }
        
        // Signal the completion of operation
        self.state = DRAsyncOperationStateFinished;
    }
}

@end
