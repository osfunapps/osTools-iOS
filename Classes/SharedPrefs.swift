//
//  SharedPrefs.swift
//  SimpleHttpDriver
//
//  Created by Oz Shabat on 21/12/2018.
//  Copyright © 2018 osApps. All rights reserved.
//

import Foundation

/// this class responsibility is to handle all of the read/write of simple variables (for saving objects, consider using CoreDataHandler)
public class SharedPrefs {
    
    /// will save an object into the shared prefs by key
    public static func setValue(_ key: String, _ value: Any?) {
        if value == nil {
            clearValue(key: key)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
    
    /// Will remove a value from the shared preferences
    public static func clearValue(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        
    }
    
    
    /// Will read a string from the shared prefs by key
    public static func getString(_ key: String, defaultValue: String? = nil) -> String? {
        guard let value = UserDefaults.standard.string(forKey: key) else {
            return defaultValue
        }
        
        return value
    }

    /// will read an int from the shared prefs by key.
    /// the default value is nil.
    public static func getInt(_ key: String, defVal: Int? = 0) -> Int? {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: key) == nil {
            return defVal
        } else {
            return preferences.integer(forKey: key)
        }
    }
    
    /// will read a long from the shared prefs by key.
    public static func getLong(_ key: String, defVal: Int? = 0) -> CLong? {
        let preferences = UserDefaults.standard
        guard let strRepr = preferences.string(forKey: key) else {
            return defVal
        }
        return CLong(strRepr)!
    }

    /// will read a string array from the shared prefs by key.
    public static func getStringArray(_ key: String) -> [String]? {
        return UserDefaults.standard.stringArray(forKey: key)
    }
    
    /// will read a dictionary from the shared prefs by key
    public static func getDictionary<T>(_ key: String) -> [String: T]? {
        return UserDefaults.standard.dictionary(forKey: key) as? [String: T]
    }
    
    
    /// will read a double from the shared prefs by key.
    /// the default value is 0.
    public static func getDouble(_ key: String) -> Double {
        let preferences = UserDefaults.standard
        return preferences.double(forKey: key)
    }
    
    
    /// will read a bool from the shared prefs by key.
    ///the default value is false.
    public static func getBool(_ key: String) -> Bool {
        let preferences = UserDefaults.standard
        return preferences.bool(forKey: key)
    }
    
    
    /// will save an object from the shared prefs by key
    @available(iOS 11.0, *)
    public static func setObj(key: String, obj: Any) {
        let userDefaults = UserDefaults.standard
        do {
            let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: obj, requiringSecureCoding: false)
            userDefaults.set(encodedData, forKey: key)
            print("Done!")
        } catch(let e) {
            print(e)
        }
    }
    
    /// will save a list of  objects
    public class func setObjList<T: Codable>(key: String, objs: [T]) {
        guard let data = try? JSONEncoder().encode(objs) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    public static func getObjList<T: Codable>(key: String) -> [T] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let objList = try? JSONDecoder().decode([T].self, from: data)
        else { return []}
        return objList
    }

    
    /// will read an object from the shared prefs by key
    public static func getObj <T> (_ key: String, defaultVal: T? = nil) -> T? {
        
        // retrieving a value for a key
        do {
            if let data = UserDefaults.standard.data(forKey: key),
               let unarchivedObj = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T {
                return unarchivedObj
            } else {
                print("There is an issue")
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    /// will clear an object from the shared prefs by key
    public static func clearObj (_ key: String) {
        setValue(key, nil)
    }
}
