//
//  OtherTools.swift
//  OsTools
//
//  Created by Oz Shabat on 27/09/2020.
//

import Foundation

// custom error
public struct AppError : Error {
    
    var description : String
    
    
    public init(description: String) {
        self.description = description
    }
    

    var localizedDescription: String {
        return NSLocalizedString(description, comment: "")
    }
}
