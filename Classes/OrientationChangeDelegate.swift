//
//  OrientationRegistrator.swift
//  GeneralRemoteiOS
//
//  Created by Oz Shabat on 23/01/2022.
//  Copyright © 2022 osApps. All rights reserved.
//

import Foundation
import UIKit

/**
 Register to this delegate in your class if you want to get notifications about orientation changes.
 
 NOTICE: the class that reports all of the orientation changes is only the view controller. It means that in the view controller which implement this delegate should override it's viewDidLayoutSubviews() and call orientationLayoutSubviews() to get notifications.
 1) ViewDidLayoutSubviews() is called multiple times so this class also make sure that the orientation is trully changed, before notifying forward.
 2) Each of the classes which implement this delegate should hold a "lastReportedOrientation" flag and should set and get it from here. That's because the class
 that responsible for remembering the current orientation MUST be the specific view controller, or else you'll have a lot of bugs. Don't put the flag on a static instance or something!
 */
public protocol OrientationChangeDelegate {
    func setLastReportedOrientation(newOrientation: UIDeviceOrientation)
    func getLastReportedOrientation() -> UIDeviceOrientation?
    
    func orientationChangeiPadLandscape()
    func orientationChangePhoneLandscape()
    func orientationChangePhonePortrait()
    func orientationChangeiPadPortrait()
    func orientationDidChanged()
}

extension OrientationChangeDelegate {
    public func orientationDidChanged(){}
    public func orientationChangeiPadLandscape(){}
    public func orientationChangePhoneLandscape(){}
    public func orientationChangePhonePortrait(){}
    public func orientationChangeiPadPortrait(){}
}

extension OrientationChangeDelegate {
    
    /// If this instance is a view controller, call this method in your viewDidLayoutSubviews() only
    public func orientationLayoutSubviews() {
        if storeNewOrientation() {
            notifyOrientationEvent()
        }
    }
    
    public func storeNewOrientation() -> Bool {
        let orientation = Tools.getCurrentOrientation()
        
        if let lastOrientation = getLastReportedOrientation(),
           lastOrientation == orientation {
            return false
        }
        setLastReportedOrientation(newOrientation: orientation)
        return true
    }
    
    public func notifyOrientationEvent() {
        self.orientationDidChanged()
        let device = Tools.getCurrentDevice()
        
        if Tools.isPortraitOrientation() {
            if device == .phone {
                self.orientationChangePhonePortrait()
            } else {
                self.orientationChangeiPadPortrait()
            }
        } else {
            if device == .phone {
                self.orientationChangePhoneLandscape()
            } else {
                self.orientationChangeiPadLandscape()
            }
        }
    }
}
