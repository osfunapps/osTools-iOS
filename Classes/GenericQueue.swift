//
//  CompletableSemaphore.swift
//  GeneralStreamiOS
//
//  Created by Oz Shabat on 13/07/2020.
//  Copyright © 2020 osCast. All rights reserved.
//

import Foundation

/**
 This class represents a generic queue with a flushing mechanism.
 Use it if you want to
 */
public class GenericQueue<T> {
    
    // queue
    public var queue = [T]()
    private var isFlushing = false  // flushing indicator
    private var queueDispatchQueue: DispatchQueue!  // the associated dispatch queue
    public var delegate: GenericQueueDelegate<T>? = nil // an optional delegate
    
    public init(dispatchQueueName: String = "queue_dq") {
        queueDispatchQueue = DispatchQueue(label: dispatchQueueName, qos: .utility)
    }
    
    /// Will add another item to the queue. The queue will be flushed by default
    public func addToQueue(item: T, toFlush: Bool = true) {
        queue.append(item)
        if toFlush {
            flush()
        }
    }
    
    // MARK: - flush types
    private func flush() {
        if isFlushing {
            return
        }
        
        isFlushing = true
        flushNextRequest()
    }
    
    private func flushNextRequest() {
        queueDispatchQueue.async {
            guard let item = self.queue.popLast() else {
                self.isFlushing = false
                return
            }
            // report flush
            self.delegate?.GenericQueueDidFlush(item: item)
            
            // run recursively again
            self.flushNextRequest()
        }
    }
}

