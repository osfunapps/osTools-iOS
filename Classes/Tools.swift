//
//  Tools.swift
//  BuildDynamicUi
//
//  Created by Oz Shabat on 30/12/2018.
//  Copyright © 2018 osApps. All rights reserved.
//

import Foundation
import UIKit

public class Tools {
    
    public static func getCurrentMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    
    public static func getCurrentMillisInt()->Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    public static func currentTimeInMicroSeconds() -> Int64
    {
        return Int64(NSDate().timeIntervalSince1970 * 1000000)
    }
    
    public static func currentTimeInSeconds()-> TimeInterval
    {
        let currentDate = Date()
        return currentDate.timeIntervalSince1970
    }
    
    
    public static func getWindowWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    public static func getWindowHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    
    public static var bottomPaddingForIphoneX: CGFloat = 0
    
    public static func storeBottomForIphoneX(viewController: UIViewController) {
        if #available(iOS 11.0, *) {
            bottomPaddingForIphoneX = viewController.view.safeAreaInsets.bottom
            print(bottomPaddingForIphoneX)
        }
    }
    
    
    public static func isIpStrLegal(_ str: String) -> Bool{
        let userIp = str.replace(",", ".")
        let legal = matches(for: "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", in: userIp)
        return !legal.isEmpty
    }
    
    public static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    /// will check if a view controller present in the backstack
    public static func isViewControllerInBackStack (
        _ navigationController: UINavigationController?,
        _ vcClass: AnyClass) -> Bool {
        return (navigationController != nil &&
            navigationController!.hasViewController(ofKind: vcClass))
    }
    /// will fire a function after a delay.
    ///
    /// @returns Task -> call task.cancel() to cancel the timed action
    public static func timedFunc (_ funcc: @escaping (() -> ()), _ time: Int) -> DispatchWorkItem {
        let task = DispatchWorkItem {
            funcc()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(time), execute: task)
        
        return task
    }
    
    /// will fire a function after a delay.
    ///
    /// @returns Task -> call task.cancel() to cancel the timed action
    public static func timedFunc2 (_ time: Int, _ funcc: @escaping (() -> ())) -> DispatchWorkItem {
        let task = DispatchWorkItem {
            funcc()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(time), execute: task)
        
        return task
    }
    
    /// Will fire a task in the background after a delay, and suspend the current thread while doing so
    ///
    /// task -> the task at hand
    /// qot -> the dispatchers queue
    /// millisToRun -> in how many milliseconds to start running
    public static func doFutureTaskSync(task: DispatchWorkItem, qos: DispatchQoS.QoSClass, millisToRun: Int) {
        DispatchQueue.global(qos: qos).asyncAfter(deadline: .now() + .milliseconds(millisToRun)){
            task.perform()
        }
    }

    /// Will fire a task on the after a delay, and suspend the current thread while doing so
    ///
    /// task -> the task at hand
    /// qot -> the dispatchers queue
    /// millisToRun -> in how many milliseconds to start running
    public static func doSuspendedFutureAsyncTask(task: DispatchWorkItem, millisToRun: Int, qos: DispatchQoS.QoSClass = .utility) {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global(qos: qos).asyncAfter(deadline: .now() + .milliseconds(millisToRun)){
            task.perform()
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    
    //    public static func buildRegualAndBoldText(regualText: String,
    //                                       boldiText: String,
    //                                       font: UIFont) -> NSAttributedString {
    //
    //        return attributedString
    //    }
    
    
    
    /// will fire a function after a millis delay on the main thread
    public static func millisTimedTaskMain(_ task: DispatchWorkItem, _ timeMillis: CLong) -> DispatchWorkItem {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(timeMillis), execute: task)
        return task
    }
    
    /// will fire a function after a millis delay on a background thread
    public static func millisTimedTaskBackground(_ task: DispatchWorkItem, _ timeMillis: Int64, _ qos: DispatchQoS.QoSClass) -> DispatchWorkItem {
        DispatchQueue.global(qos: qos).asyncAfter(deadline: DispatchTime.now() + .milliseconds(CLong(timeMillis)), execute: task)
        return task
    }
    
    
    /// will fire a task after a delay.
    ///
    public static func timedTask(_ task: DispatchWorkItem, _ timeSec: Int? = nil, _ timeFraction: Double? = nil) {
        //todo: not sure if works~
        if(timeSec != nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeSec!), execute: task)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeFraction!, execute: task)
        }
        
    }
    
    /// will generate a random number between a range. Example:
    /// Tools.randomNumber(inRange: 0...30)
    public static func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
        let length = Int64(range.upperBound - range.lowerBound + 1)
        let value = Int64(arc4random()) % length + Int64(range.lowerBound)
        return T(value)
    }
    
    /// will return true if the char is of a language
    public static func isLanguageChar(possibleChar: String) -> Bool {
        if(possibleChar.count > 1){
            return false
        }
        return (possibleChar.range(of: "[\\p{Alnum},\\s#\\-.]+", options: .regularExpression, range: nil, locale: nil) != nil)
    }
    
    /// will change the title of the back button on a view controller with a navigation
    public static func setBackButtonTitle(_ viewController: UIViewController, _ title: String) {
        viewController.navigationController?.navigationBar.topItem?.title = title;
    }
    
    /// will return the top most view controller in the back stack
    public static func getLastViewController(_ viewController: UIViewController) -> UIViewController? {
        let controllersCount = viewController.navigationController?.viewControllers.count
        if(controllersCount != nil) {
            return viewController.navigationController?.viewControllers[controllersCount! - 1]
        } else {
            return nil
        }
    }
    
    /// will lock/unlock view
    public static func lockView(view: UIView, lock: Bool){
        if(lock){
            view.isUserInteractionEnabled = false
            view.alpha = 0.5
        } else {
            view.isUserInteractionEnabled = true
            view.alpha = 1
        }
    }
    
    /// will return the string representation of a buffer (for socket handling)
    public static func uint8ArrToString(arr: [UInt8]) -> String? {
        return arr.description
    }
    
    /// will return a custom error
    public static func customErr(msg: String, code: Int) -> NSError {
        return NSError(domain: msg, code: code)
    }
    
}

/**
 substring example:
 let s = "hello"
 s[0..<3] // "hel"
 s[3..<s.count] // "lo"
 **/
