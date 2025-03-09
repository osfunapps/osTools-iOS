//
//  GyroImpl.swift
//  DrawerProject
//
//  Created by Oz Shabat on 24/01/2019.
//  Copyright © 2019 osFunApps. All rights reserved.
//

import Foundation
import CoreMotion

public final class GyroManager {
    public static let shared = GyroManager()
    private init() {}

    private let motionManager = CMMotionManager()
    private var timer: Timer?
    
    /// The closure provided by the caller that will be invoked on each update.
    public var gyroUpdateHandler: ((CMGyroData) -> Void)?

    /// Starts listening for gyro events. The provided closure is called every `checkInterval` seconds if new data is available.
    ///
    /// - Parameters:
    ///   - checkInterval: The time interval between gyro data checks.
    ///   - gyroUpdateHandler: The closure to call with new gyro data.
    public func startListening(checkInterval: TimeInterval,
                               gyroUpdateHandler: @escaping (CMGyroData) -> Void) {
        // Save the handler so that it persists for the lifetime of our updates.
        self.gyroUpdateHandler = gyroUpdateHandler
        motionManager.startGyroUpdates()
        
        // Use a block-based Timer to avoid an extra selector. The block will capture self weakly.
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            guard let self = self,
                  let gyroData = self.motionManager.gyroData else { return }
            // Directly call the caller's handler with the data.
            self.gyroUpdateHandler?(gyroData)
        }
    }

    /// Stops listening for gyro events.
    public func stopListening() {
        timer?.invalidate()
        timer = nil
        motionManager.stopGyroUpdates()
        gyroUpdateHandler = nil
    }
}
