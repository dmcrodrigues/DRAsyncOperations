# DRAsyncOperations

[![CocoaPods-Version](https://img.shields.io/cocoapods/v/DRAsyncOperations.svg)](#)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/Platform-ios%20%7C%20osx%20%7C%20watchos%20%7C%20tvos-lightgrey.svg?style=flat)](#)

Implementation of a concurrent `NSOperation` to abstract and help the creation of asynchronous operations.

## Motivation

> We code in an asynchronous world. We promise.
>
> -- <cite>[PromiseKit](http://promisekit.org)</cite>

Every iOS developer certainly agrees with this statement, a great part of our code is highly asynchronous and this brings a few challenges to us. Luckily, we have a few mechanisms to structure our business logic, `NSOperation` in combination with `NSOperationQueue` is one of them, it's powerful and flexible.

However, despite all the flexibility, if you need to make an asynchronous call on a `NSOperation` you're doomed. Remember that a `NSOperation` will finish right after the `-main` method returns. So, you will probably end up using a semaphore or something similar to lock the operation while the async call is running otherwise it will finish before time. This doesn't feel right.

Actually, you're not completely doomed, due the great flexibility offered by `NSOperation` you're able to create a concurrent operation where you can control exactly when the operation should be considered finished and with this finish the operation only after the async call have completed.

Implement a concurrent operation it's not hard but there're a few things that you will need to implement in every operation of this kind. This is the main reason behind `DRAsyncOperation`, a class that implements the base functionality required to use concurrent operations and, consequently, use asynchronous code in `NSOperation`s.

## Installation

### CocoaPods

```pod 'DRAsyncOperations'```

### Carthage

```github "dmcrodrigues/DRAsyncOperations"```

### Manually

Drag all files located in `DRAsyncOperation` folder to your project and you're done. You can also import the Xcode project into your workspace as a dependency.

## Usage

Implementing an asynchronous operation using `DRAsyncOperation` is straightforward and it may seem very similar to implementing a custom `NSOperation`.

1. Subclass `DRAsyncOperation`;
2. Override the method `-asyncTask;` where you implement your asynchronous code, you can think of it as the equivalent of `-main` method from non-concurrent operations;
3. When your asynchronous code finishes, call the method `-finish` to finish the operation, this part is new comparing to `NSOperation`.

> The methods referred above are available in `DRAsyncOperationSubclass.h`.

### Block API

You can also create an asynchronous operation using a simple block using `DRAsyncBlockOperation` which may seem very similar to a `NSBlockOperation`.

### Start operations manually

If you create an instance of `DRAsyncOperation` and then call `-start` to manually start the operation you should be aware that this call may not block until completion due the asynchronous nature of this operations. If you want the same behavior of a non-concurrent operation you should invoke `-waitUntilFinished` after `-start`.

## Examples

### Objetive-C


#### 1. Encapsulate an async task in a operation

```objective-c

// DRNetworkAsyncOperation.h

#import "DRAsyncOperation.h"

@interface DRNetworkAsyncOperation : DRAsyncOperation

@end

// DRNetworkAsyncOperation.m

#import "DRNetworkAsyncOperation.h"
#import "DRAsyncOperationSubclass.h"

@implementation DRNetworkAsyncOperation

- (void)asyncTask
{
    NSURL *githubURL = [NSURL URLWithString:@"https://github.com"];

    [[NSURLSession sharedSession] dataTaskWithURL:githubURL
                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        // Do your stuff ...

        // When you're done, finish the operation
        [self finish];
    }];
}

@end

```

#### 2. Encapsulate an async task in a block

```objective-c

NSOperationQueue *queue;

CLGeocoder *geocoder;
CLLocation *location;

NSOperation *asyncOperation = [DRAsyncBlockOperation asyncBlockOperationWithBlock:^(DRAsyncBlockOperationFinishBlock finish) {

    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {

        // Do your stuff ...

        // When you're done, finish the operation
        finish();
    }];

}];

[queue addOperation:asyncOperation];

```

## Swift

Swift is supported out-of-the-box, you only need to import the relevant headers in your Bridging Header.

```objective-c

// If you want to implement async tasks in operations
#import "DRAsyncOperation.h"
#import "DRAsyncOperationSubclass.h"

// If you want to implement async tasks in blocks
#import "DRAsyncBlockOperation.h"

```

The block API in Swift it's more compact in comparison with Objective-C.

```swift

var queue: NSOperationQueue

var geocoder: CLGeocoder
var location: CLLocation

var asyncOperation: DRAsyncBlockOperation!

asyncOperation = DRAsyncBlockOperation { (finish) -> Void in

    // This is automatically checked for you at the beginning of the operation but you could check it during your execution
    if asyncOperation.isCancelled() {
        finish()
        return
    }

    geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

        // Do your stuff ...

        // When you're done, finish the operation
        finish()

    })
}

queue.addOperation(asyncOperation)

```

## Creator

[David Rodrigues](https://github.com/dmcrodrigues)
[@dmcrodrigues](https://twitter.com/dmcrodrigues)

## License

DRAsyncOperation is released under the [MIT License](http://www.opensource.org/licenses/MIT).
