//
//  ApplicationEventObserver.swift
//  ApplicationEventObserver
//
//  Created by Suguru Kishimoto on 2015/12/27.
//
//

import Foundation
import UIKit

public enum ApplicationEventType {
    case DidFinishLaunching
    case WillEnterForeground
    case DidEnterBackground
    case WillResignActive
    case DidBecomeActive
    case DidReceiveMemoryWarning
    case WillTerminate
    case SignificantTimeChange
    case WillChangeStatusBarOrientation
    case DidChangeStatusBarOrientation
    case WillChangeStatusBarFrame
    case DidChangeStatusBarFrame
    case BackgroundRefreshStatusDidChange
    
    private static let eventTypes: [String: ApplicationEventType] = [
        UIApplicationDidFinishLaunchingNotification:               .DidFinishLaunching,
        UIApplicationWillEnterForegroundNotification:              .WillEnterForeground,
        UIApplicationDidEnterBackgroundNotification:               .DidEnterBackground,
        UIApplicationWillResignActiveNotification:                 .WillResignActive,
        UIApplicationDidBecomeActiveNotification:                  .DidBecomeActive,
        UIApplicationDidReceiveMemoryWarningNotification:          .DidReceiveMemoryWarning,
        UIApplicationWillTerminateNotification:                    .WillTerminate,
        UIApplicationSignificantTimeChangeNotification:            .SignificantTimeChange,
        UIApplicationWillChangeStatusBarOrientationNotification:   .WillChangeStatusBarOrientation,
        UIApplicationDidChangeStatusBarOrientationNotification:    .DidChangeStatusBarOrientation,
        UIApplicationWillChangeStatusBarFrameNotification:         .WillChangeStatusBarFrame,
        UIApplicationDidChangeStatusBarFrameNotification:          .DidChangeStatusBarFrame,
        UIApplicationBackgroundRefreshStatusDidChangeNotification: .BackgroundRefreshStatusDidChange
    ]
    
    public var notificationName: String {
        return self.dynamicType.eventTypes
            .flatMap{ $0.1 == self ? $0.0 : nil }
            .first ?? ""
    }
    
    public static var allEventTypes: [ApplicationEventType] {
        return eventTypes.values.map { $0 }
    }
    
    public static var allNotificationNames: [String] {
        return eventTypes.keys.map { $0 }
    }
    
    public init?(notificationName name: String) {
        guard let type = self.dynamicType.eventTypes[name] else {
            return nil
        }
        self = type
    }
    
}

public struct ApplicationEvent {
    private(set) public var type: ApplicationEventType
    private(set) public var value: AnyObject?
    
    private static let notificationValueKeys: [String: String]  = [
        UIApplicationWillChangeStatusBarOrientationNotification: UIApplicationStatusBarOrientationUserInfoKey,
        UIApplicationDidChangeStatusBarOrientationNotification:  UIApplicationStatusBarOrientationUserInfoKey,
        UIApplicationWillChangeStatusBarFrameNotification:       UIApplicationStatusBarFrameUserInfoKey,
        UIApplicationDidChangeStatusBarFrameNotification:        UIApplicationStatusBarFrameUserInfoKey
    ]
    
    public init?(notification: NSNotification) {
        guard let type = ApplicationEventType(notificationName: notification.name) else {
            return nil
        }
        
        self.type = type
        
        if let
            key = self.dynamicType.notificationValueKeys[notification.name],
            value = notification.userInfo?[key] {
            self.value = value
        }
    }
}

public typealias ApplicationEventBlock = ApplicationEvent -> Void

public class ApplicationEventObserver {
    
    private lazy var nc = NSNotificationCenter.defaultCenter()
    
    private var callBack: ApplicationEventBlock?

    private var enabled: Bool = false
    public init() {
        ApplicationEventType.allNotificationNames.forEach {
            nc.addObserver(self, selector: "notified:", name: $0, object: nil)
        }
    }
    
    deinit {
        dispose()
        nc.removeObserver(self)
    }
    
    public func subscribe(callBack: ApplicationEventBlock) {
        self.callBack = callBack
        resume()
    }
    
    public func dispose() {
        suspend()
        self.callBack = nil
    }
    
    public func resume() {
        enabled = true
    }
    
    public func suspend() {
        enabled = false
    }
}

private extension ApplicationEventObserver {
    @objc private func notified(notification: NSNotification) {
        if !enabled { return }
        guard let event = ApplicationEvent(notification: notification) else {
            return
        }
        self.callBack?(event)
    }
}