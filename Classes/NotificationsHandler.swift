//
//  SchedulePush.swift
//  BuildingRoutines
//
//  Created by Oz Shabbat on 01/05/2023.
//

import Foundation
import UserNotifications
import UIKit

/// A utility class to manage and handle local and remote notifications.
///
/// The NotificationsHandler class provides a convenient way to request notification permissions, check the current authorization status, and schedule local notifications. It handles both local and remote notifications, and offers methods to request permissions, check permissions status, and schedule local notifications with a title, body, and optional image URL.
///
/// Example usage:
///
///     // Request notification permissions
///     NotificationsHandler.requestNotificationPermission { granted, error in
///         if granted {
///             // Schedule a local notification
///             NotificationsHandler.scheduleLocalNotification(at: date, withTitle: "Title", andBody: "Body", andIdentifier: "myIdentifier")
///         }
///     }
///
///     // Check the current notification authorization status
///     NotificationsHandler.getNotificationPermissionStatus { status in
///         print("Notification authorization status: \(status)")
///     }
///
///
/// Also in your AppDelegate:
///
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///
///         // register the delegate
///         UNUserNotificationCenter.current().delegate = self
///         if launchOptions?[.localNotification] is UILocalNotification,
///         localNotification.identifier == "myIdentifier" {
///             // came from notification click!
///         }
///     }
///
///     extension AppDelegate: UNUserNotificationCenterDelegate {
///
///         func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
///             print("the user clicked on a notification while being already in the app!")
///             completionHandler()
///         }
///     }
///
public class NotificationsHandler {
    
    /// Requests the user's permission to send notifications.
    ///
    /// This function requests the user's permission to send both local and remote notifications, including alert and sound options. The completion handler is called with a boolean value indicating whether the permission was granted and an optional error.
    ///
    /// - Important: This function should be called from the main dispatch queue.
    ///
    /// - Parameter completion: A closure that is called with the result of the authorization request.
    /// - Parameter granted: A boolean value indicating whether the permission was granted.
    /// - Parameter error: An optional error if there was an issue with the authorization request.
    public static func requestNotificationPermission(completion: @escaping (Bool, Error?) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: completion)
    }
    
    
    /// Retrieves the current notification permission status.
    ///
    /// This function retrieves the current notification permission status without prompting the user for authorization. The completion handler is called with the current UNAuthorizationStatus.
    ///
    /// - Important: This function should be called from the main dispatch queue.
    ///
    /// - Parameter completion: A closure that is called with the current notification permission status.
    /// - Parameter status: The current UNAuthorizationStatus.

    public static func getNotificationPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    
    /// Schedules a local notification at the specified date with a title, body, and optional image URL.
    ///
    /// This function schedules a local notification to be delivered at the specified date. The notification includes a title, body, and an optional image URL. The completion handler is called with an optional error if there was an issue scheduling the notification.
    ///
    /// - Parameters:
    ///   - date: The date at which the notification should be delivered.
    ///   - title: The title of the notification.
    ///   - body: The body of the notification.
    ///   - imageURL: An optional URL to an image to be displayed in the notification.
    ///   - completion: An optional closure that is called with an optional error if there was an issue scheduling the notification.
    ///   - error: An optional error if there was an issue scheduling the notification.

    public static func scheduleLocalNotification(at date: Date,
                                                 withTitle title: String,
                                                 andBody body: String,
                                                 andImageURL imageURL: URL? = nil,
                                                 andIdentifier identifier: String? = nil,
                                                 completion: ((Error?) -> Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Add image attachment
        if let imageURL = imageURL {
            do {
                let attachment = try UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("Error attaching image: \(error)")
            }
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        content.identifier = identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: completion)
    }
}

public extension UILocalNotification {
    var identifier: String? {
        get {
            return userInfo?["identifier"] as? String
        }
    }
}

public extension UNMutableNotificationContent {
    var identifier: String? {
        set {
            userInfo["identifier"] = newValue
        }
        
        get {
            return userInfo["identifier"] as? String
        }
    }
}
