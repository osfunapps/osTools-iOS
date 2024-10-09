//
//  OtherTools.swift
//  OsTools
//
//  Created by Oz Shabat on 27/09/2020.
//

import Foundation

// Adding AppError enum with Equatable conformance
public enum AppError: Error, Equatable {
    case customError(String)
    case missingResources
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg
        case .missingResources:
            return "Error: Missing resources"
        }
    }
}

public func == (lhs: AppError, rhs: AppError) -> Bool {
    switch (lhs, rhs) {
    case (.missingResources, .missingResources):
        return true
    case (.customError(let lhsMessage), .customError(let rhsMessage)):
        return lhsMessage == rhsMessage
    default:
        return false
    }
}
