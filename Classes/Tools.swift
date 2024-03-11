//
//  Tools.swift
//  BuildDynamicUi
//
//  Created by Oz Shabat on 30/12/2018.
//  Copyright © 2018 osApps. All rights reserved.
//

import Foundation
import UIKit
import Network

public class Tools {
    
    /// Will imitate System.arraycopy of Java
    public static func javaSystemArraycopy(_ src: Data, _ srcPos: Int, _ dest: inout Data, _ destPos: Int, _ length: Int) {
        dest[destPos...(destPos + length - 1)] = src[srcPos...(srcPos + length - 1)]
    }
    
    /// will return the app delegate instance. Call with val appDelegate: AppDelegate? = Tools.getAppDelegate()
    public static func getAppDelegate<T>() -> T? {
        if let myDelegate = UIApplication.shared.delegate as? T {
            return myDelegate
        }
        return nil
    }
    
    /// Will return the current time in seconds
    public static func getCurrentSeconds() ->  TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    /// Will return the current time in Int64 format
    public static func getCurrentMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    /// Will return the current time in Int format
    public static func getCurrentMillisInt()->Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    /// Will return the current time in Float format
    public static func currentTimeInMilliSeconds() -> CGFloat {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return CGFloat(since1970 * 1000000)
    }
    
    /// Will return the screen's width
    public static func getWindowWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    /// Will return the screen's height
    public static func getWindowHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    
    /// Will return the button bar of iPhones x and later
    public static func getIphonesBottomBar(viewController: UIViewController) -> CGFloat {
        if #available(iOS 11.0, *) {
            return viewController.view.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    /// Will check if a string is a legal ip address
    public static func isIpStrLegal(_ str: String) -> Bool{
        let userIp = str.replace(",", ".")
        let legal = matches(for: "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", in: userIp)
        return !legal.isEmpty
    }
    
    public static func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee

                if (flags & (IFF_UP|IFF_RUNNING)) != 0 {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            let addressString = String(validatingUTF8: hostname)
                            // Filter out the loopback address
                            if addr.sa_family == UInt8(AF_INET), let addressStr = addressString, addressStr != "127.0.0.1" {
                                address = addressStr
                                break
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }

        return address
    }

    /// Will check if the WiFi is currently connected. Notice: result will be on the main thread
    /// NOTICE: ios <12.0 devices will always return true
    public static func isWifiConnected(_ completion: @escaping (Bool) -> Void) {
        if #available(iOS 12.0, *) {
            let wifiMonitor = NWPathMonitor(requiredInterfaceType: .wifi)
            wifiMonitor.start(queue: DispatchQueue.main)
            // check if wifi connected
            wifiMonitor.pathUpdateHandler = { path in
                wifiMonitor.cancel()
                let isWifi = path.status == .satisfied && path.usesInterfaceType(.wifi)
                completion(isWifi)
            }
        } else {
            completion(true)
        }
    }
    
    public static func calculateNetworkPortion(ipAddress: String?) -> String? {
        guard let ipAddress = ipAddress, let lastIndex = ipAddress.lastIndex(of: ".") else {
            return nil
        }
        return String(ipAddress[..<lastIndex])
    }


    
    /// Will return all of the matches expression of the regular expression in a given text
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
    
    /// Will run a function after a delay. The delayed function will run on the main thread
    public static func asyncMainTimedFunc(_ funcc: @escaping (() -> ()), _ seconds: Int = 0, millis: Int = 0) -> DispatchWorkItem {
        let task = DispatchWorkItem {
            funcc()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(seconds) + .milliseconds(millis), execute: task)
        return task
    }
    
    /// Will run a function after a delay. The delayed function will run on a background dq
    public static func asyncTimedFunc(_ funcc: @escaping (() -> ()),
                                      seconds: Int = 0,
                                      millis: Int = 0,
                                      qos: DispatchQoS.QoSClass = .utility) -> DispatchWorkItem {
        let task = DispatchWorkItem {
            funcc()
        }
        DispatchQueue.global(qos: qos).asyncAfter(deadline: DispatchTime.now() + .seconds(seconds) + .milliseconds(millis), execute: task)
        
        return task
    }
    
    /// Wll run a function after a delay on the main thread
    public static func asyncMainTimedTask(task: DispatchWorkItem,
                                          seconds: Int = 0,
                                          millis: Int = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds) + .milliseconds(millis), execute: task)
    }
    
    /// Wll run a function after a delay on a background thread
    public static func asyncTimedTask(task: DispatchWorkItem,
                                      seconds: Int = 0,
                                      millis: Int = 0,
                                      qos: DispatchQoS.QoSClass = .utility) {
        DispatchQueue.global(qos: qos).asyncAfter(deadline: DispatchTime.now() + .seconds(seconds) + .milliseconds(millis), execute: task)
    }
    
    /// Will return true if the char is of a language
    public static func isLanguageChar(possibleChar: String) -> Bool {
        if(possibleChar.count > 1){
            return false
        }
        return (possibleChar.range(of: "[\\p{Alnum},\\s#\\-.]+", options: .regularExpression, range: nil, locale: nil) != nil)
    }
    
    /// Will return the top most view controller in the back stack
    public static func getLastViewController(_ viewController: UIViewController) -> UIViewController? {
        let controllersCount = viewController.navigationController?.viewControllers.count
        if(controllersCount != nil) {
            return viewController.navigationController?.viewControllers[controllersCount! - 1]
        } else {
            return nil
        }
    }
    
    /// Will check if a string is a legal MAC address
    public static func isMACAddrLegal(_ addr: String) -> Bool {
        let legal = matches(for: "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})|([0-9a-fA-F]{4}\\.[0-9a-fA-F]{4}\\.[0-9a-fA-F]{4})$", in: addr)
        return !legal.isEmpty
    }
    
    /// will change the title of the back button on a view controller with a navigation
    public static func setBackButtonTitle(_ viewController: UIViewController, _ title: String) {
        viewController.navigationController?.navigationBar.topItem?.title = title;
    }
    
    /// Will generate a random mac address
    public static func generateRandomMACAddress() -> String {
        var bArr = [UInt8](repeating: 0, count: 6)
        
        let status = SecRandomCopyBytes(kSecRandomDefault, bArr.count, &bArr)
        
        if status != errSecSuccess { // Always test the status.
            return "b6:58:d9:db:c9:ee"  // random number
        }
        
        bArr[0] = UInt8((Int(bArr[0]) | 2) & -2)
        var randomMACStr = ""
        for b in bArr {
            if randomMACStr.count > 0 {
                randomMACStr += ":"
            }
            randomMACStr.append(String(format: "%02x", b))
        }
        return randomMACStr
    }
    
    /// Will join path
    public static func join(_ arguments: String...) -> String {
        return NSString.path(withComponents: arguments)
    }
    
    /// Will return the current device enum
    public static func getCurrentDevice() ->UIUserInterfaceIdiom {
        return UIDevice.current.userInterfaceIdiom
    }
    
    /// Will return the current device (iPad, iPhone etc..)
    public static func getCurrentDeviceParsed() -> String {
        switch getCurrentDevice() {
        case .carPlay: return "carPlay"
        case .mac: return "Mac"
        case .pad: return "iPad"
        case .phone: return "iPhone"
        case .tv: return "TV"
        default:
            return "device"
        }
    }
    
    /// This is shitty and buggy. Use isPortraitOrientation() instead!
    public static func getCurrentOrientation() -> UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    /// The correct way to check orientation without hassling with all of the faceUp faceDown shits out there
    public static func isPortraitOrientation() -> Bool {
        let size = UIScreen.main.bounds.size
        return size.width < size.height
    }
    
    /// Will return true if dark mode is on
    public static func isDarkMode(vc: UIViewController) -> Bool {
        if #available(iOS 12.0, *) {
            return vc.traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }
    
    /// Will set the current theme of the app
    @available(iOS 13.0, *)
    public static func setInterfaceStyle(window: UIWindow, style: UIUserInterfaceStyle, _ completion: ((Bool) -> Void)? = nil) {
        UIView.transition (with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.overrideUserInterfaceStyle = style
        }, completion: completion)
    }
    
    /// will open the developer apps in the App Strore
    public static func showDeveloperApps(developerId: String = "id1234") {
        let url = URL(string: "itms-apps://itunes.apple.com/developer/\(developerId)")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // will download an example video file to the gallery
    public static func downloadVideoFileToGallery() {
        let imageData = NSData(contentsOf: URL(string: "https://freetestdata.com/wp-content/uploads/2021/10/Free_Test_Data_1MB_MOV.mov")!)!
        let asStr = "\(NSTemporaryDirectory())temp.mov"
        
        imageData.write(toFile: asStr, atomically: true)
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(asStr) {
            UISaveVideoAtPathToSavedPhotosAlbum(asStr, nil, nil, nil)
        }
    }
    
    // will block the current thread so use with caution
    public static func delay(for time: DispatchTime) {
        CompletableSemaphore<Bool>().wait(for: time)
    }
    
    /**
     Composes an email using the device's default mail application.
     
     - Parameters:
     - emailRecipient: The main recipient of the email.
     - recipients: The CC recipients of the email. This is optional.
     - emailSubject: The subject of the email.
     - emailContent: The body content of the email.
     
     This function does not send the email itself, but prepares an email in the user's default email client.
     */
    public static func sendEmail(emailRecipient: String, recipients: String? = nil, emailSubject: String, emailContent: String) {
        var mailto = "mailto:\(emailRecipient)?subject=\(emailSubject)&body=\(emailContent)"
        if let cc = recipients {
            mailto += "&cc=\(cc)"
        }
        
        guard let url = URL(string: mailto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    /**
     Determines the size of the notch (safe area inset at the top of the screen).
     
     This function is specific to devices with iOS 11.0 and above, as it utilizes the `safeAreaInsets` property introduced in iOS 11.0.
     
     - Returns: A `CGFloat` value representing the size of the notch if present, or `nil` for devices without a notch or running on iOS versions prior to 11.0.
     
     Note: This function will return a value greater than 20 for devices with a notch, given that the standard status bar height is 20 points. For devices without a notch, the function will return 20 (status bar height) or possibly 0, depending on whether the status bar is visible.
     */
    public static func getNotchSize() -> CGFloat? {
        if #available(iOS 11.0, *) {
            let appDelegate = UIApplication.shared.delegate
            if let window = appDelegate?.window {
                return window?.safeAreaInsets.top
            }
        }
        return nil
    }
}


/**
 substring example:
 let s = "hello"
 s[0..<3] // "hel"
 s[3..<s.count] // "lo"
 **/
