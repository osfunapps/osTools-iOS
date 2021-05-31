//
//  Gee.swift
//  OsTools
//
//  Created by Oz Shabat on 31/05/2021.
//

import Foundation

/// Implement this delegate to get reports about any event related to the generic queue (when flush and more)
public class GenericQueueDelegate<T> {
    public func GenericQueueDidFlush(item: T){}
}

