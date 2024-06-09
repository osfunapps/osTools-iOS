//
//  OtherTools.swift
//  OsTools
//
//  Created by Oz Shabat on 27/09/2020.
//

import Foundation


public enum AppError: Error {
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
