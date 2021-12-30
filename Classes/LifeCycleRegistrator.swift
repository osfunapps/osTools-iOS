//
//  OnStandbyHandler.swift
//  GeneralRemoteiOS
//
//  Created by Oz Shabat on 30/04/2019.
//  Copyright © 2019 osFunApps. All rights reserved.
//

import Foundation
import UIKit

// this class will help a view controller register/unregister to/from life cycle events (when the view controller go or come back from standby, for example). DO NOT FORGET TO UNREGISTER FROM THE EVENTS OR YOULL DIE
public class LifeCycleRegistrator {

    /// register to onResume events
    public static func registerToLifeCycleEvents(viewController: UIViewController, delegate: LifeCycleDelegate) {
        NotificationCenter.default.addObserver(viewController, selector: #selector(delegate.appDidReturnedFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(viewController, selector: #selector(delegate.appDidEnteredBackground), name: UIScene.willDeactivateNotification, object: nil)
        } else {
             NotificationCenter.default.addObserver(viewController, selector: #selector(delegate.appDidEnteredBackground), name: UIApplication.willResignActiveNotification, object: nil)
        }
        
    }

    /// unregister from onResume events
    public static func unregisterFromLifeCycleEvents(viewController: UIViewController) {
        NotificationCenter.default.removeObserver(viewController, name: UIApplication.didBecomeActiveNotification, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(viewController, name: UIScene.willDeactivateNotification, object: nil)
        } else {
             NotificationCenter.default.removeObserver(viewController, name: UIApplication.willResignActiveNotification, object: nil)
        }
    }
}

@objc public protocol LifeCycleDelegate: AnyObject {
    @objc func appDidEnteredBackground()
    @objc func appDidReturnedFromBackground()
}
