//
//  LightDarkThemeHandler.swift
//  GeneralRemoteiOS
//
//  Created by Oz Shabat on 06/02/2022.
//  Copyright © 2022 osApps. All rights reserved.
//

import Foundation
import UIKit

/// Will hold the current theme type
public class LightDarkThemeHandler {
    
    /// Finals
    private static let SP_CURRENT_INTERFACE_STYLE = "current_interface_style"
    
    /// Call in your app delegate to prepare the app for the last used theme
    @available(iOS 12.0, *)
    public static func appDidInit(window: UIWindow) {
        let currStyle = getCurrentInterfaceStyle()
        applyStyle(window: window, style: currStyle)
    }
    
    /// Will return the current theme used
    @available(iOS 12.0, *)
    public static func getCurrentInterfaceStyle() -> UIUserInterfaceStyle {
        if let interfaceStyleInt = getSavedStyle(),
           let interfaceStyle = UIUserInterfaceStyle.init(rawValue: interfaceStyleInt) {
            return interfaceStyle
        }
        return .unspecified
    }
    
    /// Will set the current style of the app by a theme
    @available(iOS 12.0, *)
    public static func setCurrStyle(window: UIWindow, style: UIUserInterfaceStyle) -> Bool {
        saveNewStyle(newStyle: style.rawValue)
        return applyStyle(window: window, style: style)
    }
    
    /// Will set the current style of the app by a theme
    @discardableResult
    @available(iOS 12.0, *)
    private static func applyStyle(window: UIWindow, style: UIUserInterfaceStyle) -> Bool {
        if #available(iOS 13.0, *) {
            Tools.setInterfaceStyle(window: window, style: style)
            return true
        } else {
           return false
        }
    }
    
    private static func getSavedStyle() -> Int? {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: SP_CURRENT_INTERFACE_STYLE) == nil {
            return nil
        } else {
            return preferences.integer(forKey: SP_CURRENT_INTERFACE_STYLE)
        }
    }
    
    private static func saveNewStyle(newStyle: Int?) {
        if newStyle == nil {
            clearValue(key: SP_CURRENT_INTERFACE_STYLE)
        } else {
            let preferences = UserDefaults.standard
            preferences.set(newStyle, forKey: SP_CURRENT_INTERFACE_STYLE)
        }
    }
    
    /// Will remove a value from the shared preferences
    private static func clearValue(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}
