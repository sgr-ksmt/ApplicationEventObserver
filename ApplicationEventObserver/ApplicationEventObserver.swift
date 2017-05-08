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
    case didFinishLaunching
    case willEnterForeground
    case didEnterBackground
    case willResignActive
    case didBecomeActive
    case didReceiveMemoryWarning
    case willTerminate
    case significantTimeChange
    case willChangeStatusBarOrientation
    case didChangeStatusBarOrientation
    case willChangeStatusBarFrame
    case didChangeStatusBarFrame
    case backgroundRefreshStatusDidChange
    
    fileprivate static let eventTypes: [NSNotification.Name: ApplicationEventType] = [
        NSNotification.Name.UIApplicationDidFinishLaunching:               .didFinishLaunching,
        NSNotification.Name.UIApplicationWillEnterForeground:              .willEnterForeground,
        NSNotification.Name.UIApplicationDidEnterBackground:               .didEnterBackground,
        NSNotification.Name.UIApplicationWillResignActive:                 .willResignActive,
        NSNotification.Name.UIApplicationDidBecomeActive:                  .didBecomeActive,
        NSNotification.Name.UIApplicationDidReceiveMemoryWarning:          .didReceiveMemoryWarning,
        NSNotification.Name.UIApplicationWillTerminate:                    .willTerminate,
        NSNotification.Name.UIApplicationSignificantTimeChange:            .significantTimeChange,
        NSNotification.Name.UIApplicationWillChangeStatusBarOrientation:   .willChangeStatusBarOrientation,
        NSNotification.Name.UIApplicationDidChangeStatusBarOrientation:    .didChangeStatusBarOrientation,
        NSNotification.Name.UIApplicationWillChangeStatusBarFrame:         .willChangeStatusBarFrame,
        NSNotification.Name.UIApplicationDidChangeStatusBarFrame:          .didChangeStatusBarFrame,
        NSNotification.Name.UIApplicationBackgroundRefreshStatusDidChange: .backgroundRefreshStatusDidChange
    ]
    
    public var notificationName: NSNotification.Name? {
        return type(of: self).eventTypes
            .flatMap{ $0.1 == self ? $0.0 : nil }
            .first ?? nil
    }
    
    public static var allEventTypes: [ApplicationEventType] {
        return eventTypes.values.map { $0 }
    }
    
    public static var allNotificationNames: [NSNotification.Name] {
        return eventTypes.keys.map { $0 }
    }
    
    public init?(notificationName name: NSNotification.Name) {
        guard let type = type(of: self).eventTypes[name] else {
            return nil
        }
        self = type
    }
    
}

public struct ApplicationEvent {
    fileprivate(set) public var type: ApplicationEventType
    fileprivate(set) public var value: Any?
    
    fileprivate static let notificationValueKeys: [NSNotification.Name: String]  = [
        NSNotification.Name.UIApplicationWillChangeStatusBarOrientation: UIApplicationStatusBarOrientationUserInfoKey,
        NSNotification.Name.UIApplicationDidChangeStatusBarOrientation:  UIApplicationStatusBarOrientationUserInfoKey,
        NSNotification.Name.UIApplicationWillChangeStatusBarFrame:       UIApplicationStatusBarFrameUserInfoKey,
        NSNotification.Name.UIApplicationDidChangeStatusBarFrame:        UIApplicationStatusBarFrameUserInfoKey
    ]
    
    public init?(notification: Foundation.Notification) {
        guard let type = ApplicationEventType(notificationName: notification.name) else {
            return nil
        }
        
        self.type = type
        
        if let
            key = type(of: self).notificationValueKeys[notification.name],
            let value = notification.userInfo?[key] {
            self.value = value
        }
    }
}

public typealias ApplicationEventBlock = (ApplicationEvent) -> Void

public protocol ApplicationEventObserverProtocol {

    func subscribe(_ callBack: @escaping ApplicationEventBlock)
    func dispose()
    func resume()
    func suspend()
}

open class ApplicationEventObserver: ApplicationEventObserverProtocol {
    
    fileprivate lazy var nc = NotificationCenter.default
    
    fileprivate var callBack: ApplicationEventBlock?

    fileprivate var enabled: Bool = false
    public init() {
        ApplicationEventType.allNotificationNames.forEach {
            nc.addObserver(self, selector: #selector(ApplicationEventObserver.notified(_:)), name: $0, object: nil)
        }
    }
    
    deinit {
        dispose()
        nc.removeObserver(self)
    }
    
    open func subscribe(_ callBack: @escaping ApplicationEventBlock) {
        self.callBack = callBack
        resume()
    }
    
    open func dispose() {
        suspend()
        self.callBack = nil
    }
    
    open func resume() {
        enabled = true
    }
    
    open func suspend() {
        enabled = false
    }
}

private extension ApplicationEventObserver {
    @objc func notified(_ notification: Foundation.Notification) {
        if !enabled { return }
        guard let event = ApplicationEvent(notification: notification) else {
            return
        }
        self.callBack?(event)
    }
}
