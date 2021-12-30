//
//  GyroImpl.swift
//  DrawerProject
//
//  Created by Oz Shabat on 24/01/2019.
//  Copyright © 2019 osFunApps. All rights reserved.
//

import Foundation
import CoreMotion

/// A simple class to listen to any Gyro events
public class GyroImpl {
    
    // singletone
    public static let shared = GyroImpl()
    private init() {}
    
    // instances
    private let motionManager = CMMotionManager()
    private var timer: Timer!
    public var delegate: GyroEventDelegate?
    
    /// Will start listening to Gyro events
    public func startListeningToEvents(checkEvery: TimeInterval, delegate: GyroEventDelegate) {
        self.delegate = delegate
        motionManager.startGyroUpdates()
        timer = Timer.scheduledTimer(timeInterval: checkEvery,
                                     target: self,
                                     selector: #selector(gyroDidUpdate),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    /// Will be called with each update to the gyroscope
    @objc private func gyroDidUpdate() {
        if let gyroData = motionManager.gyroData {
            delegate?.gyroDidChanged(data: gyroData)
        }
    }
    
    /// Will stop listening to Gyro events
    public func stopListeningToEvents() {
        timer?.invalidate()
        motionManager.stopGyroUpdates()
    }
}

public protocol GyroEventDelegate {
    func gyroDidChanged(data: CMGyroData)
}

