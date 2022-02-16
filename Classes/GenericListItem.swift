//
//  GenericListItem.swift
//  GeneralRemoteiOS
//
//  Created by Oz Shabat on 01/02/2022.
//  Copyright © 2022 osApps. All rights reserved.
//

import Foundation

public struct GenericListItem: Codable {
    public var name: String
    public var id: String?
    
    public init(name: String, id: String?) {
        self.name = name
        self.id = id
    }
    
    public func copy() -> GenericListItem {
        return GenericListItem(name: name, id: id)
    }
}
