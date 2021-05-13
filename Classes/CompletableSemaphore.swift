//
//  CompletableSemaphore.swift
//  GeneralStreamiOS
//
//  Created by Oz Shabat on 13/07/2020.
//  Copyright © 2020 osCast. All rights reserved.
//

import Foundation

/**
 Use this class if you want a semaphore with a completable result
 */
public class CompletableSemaphore<T> {
    
    public var semaphore = DispatchSemaphore(value: 0)
    public var isCompleted = false
    public var result: T!
    
    public func getCompleted() -> T {
        return result
    }
    
    public func complete(result: T) {
        self.result = result
        isCompleted = true
        semaphore.signal()
    }
    
    public func wait(_ timeoutSecs: Int = -1) -> T {
        if(timeoutSecs != -1) {
            semaphore.wait(timeout: .now() + .seconds(timeoutSecs))
        } else {
            semaphore.wait()
        }
        return result
    }
}
