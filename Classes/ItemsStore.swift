//
//  MainConfigRemotesItemsStore.swift
//  BuildDynamicUi
//
//  Created by Oz Shabat on 08/01/2019.
//  Copyright © 2019 osApps. All rights reserved.
//

// a generic Items Store class to serve as a data source to tables
public class ItemsStore<T> {
    
    public init() {}
    
    // will hold the list of items in the data source
    private var items = [T]()
    
    public func setItems(items: [T]){
        self.items = items
    }
    
    public func addItem(_ item: T){
        items.append(item)
    }
    
    public func insertItem(_ item: T, _ location: Int){
        items.insert(item, at: location)
    }
    
    public func getItemAt(_ idx: Int) -> T?{
        if (idx >= items.count){
            return nil
        } else {
            return items[idx]
        }
    }
    
    public func count() -> Int {
        return items.count
    }
    
    public func getItems() -> [T] {
        return items
    }
    
    public func clearAllItems(){
        items.removeAll()
    }
    
    public func removeItem(at: Int) {
        items.remove(at: at)
    }
}
