//
//  CompletableSemaphore.swift
//  GeneralStreamiOS
//
//  Created by Oz Shabat on 13/07/2020.
//  Copyright © 2020 osCast. All rights reserved.
//

import Foundation

/**
 Use this class if you want a semaphore with a completable result.
 Notice: the made instance have a "wait(for timeout) function. It means that this semaphore can also return nil response (if the the timeout ended without a signal)
 */
public class CompletableSemaphore<T> {
    
    public var semaphore = DispatchSemaphore(value: 0)
    public var isCompleted = false
    public var result: T?
    
    public init() {}
    
    public func getCompleted() -> T? {
        return result
    }
    
    public func complete(result: T?) {
        if isCompleted {
            return
        }
        isCompleted = true
        self.result = result
        semaphore.signal()
    }
    
    
    @discardableResult
    public func wait(for timeout: DispatchTime? = nil) -> T? {
        if let timeout = timeout {
            _ = semaphore.wait(timeout: timeout)
        } else {
            semaphore.wait()
        }
        return result
    }
}
