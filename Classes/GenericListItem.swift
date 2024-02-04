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
    public var imgRes: String?
    public init(name: String, id: String?, imgRes: String? = nil) {
        self.name = name
        self.id = id
        self.imgRes = imgRes
    }
    
    public func copy() -> GenericListItem {
        return GenericListItem(name: name, id: id, imgRes: imgRes)
    }
}
