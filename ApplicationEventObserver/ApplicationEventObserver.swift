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
        UIApplication.didFinishLaunchingNotification: .didFinishLaunching,
        UIApplication.willEnterForegroundNotification: .willEnterForeground,
        UIApplication.didEnterBackgroundNotification: .didEnterBackground,
        UIApplication.willResignActiveNotification: .willResignActive,
        UIApplication.didBecomeActiveNotification: .didBecomeActive,
        UIApplication.didReceiveMemoryWarningNotification: .didReceiveMemoryWarning,
        UIApplication.willTerminateNotification: .willTerminate,
        UIApplication.significantTimeChangeNotification: .significantTimeChange,
        UIApplication.willChangeStatusBarOrientationNotification: .willChangeStatusBarOrientation,
        UIApplication.didChangeStatusBarOrientationNotification: .didChangeStatusBarOrientation,
        UIApplication.willChangeStatusBarFrameNotification: .willChangeStatusBarFrame,
        UIApplication.didChangeStatusBarFrameNotification: .didChangeStatusBarFrame,
        UIApplication.backgroundRefreshStatusDidChangeNotification: .backgroundRefreshStatusDidChange
    ]

    public var notificationName: NSNotification.Name? {
        return type(of: self).eventTypes
            .compactMap { $0.1 == self ? $0.0 : nil }
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
    public let type: ApplicationEventType
    public let value: Any?

    fileprivate static let notificationValueKeys: [NSNotification.Name: String]  = [
        UIApplication.willChangeStatusBarOrientationNotification: UIApplication.statusBarOrientationUserInfoKey,
        UIApplication.didChangeStatusBarOrientationNotification: UIApplication.statusBarOrientationUserInfoKey,
        UIApplication.willChangeStatusBarFrameNotification: UIApplication.statusBarFrameUserInfoKey,
        UIApplication.didChangeStatusBarFrameNotification: UIApplication.statusBarFrameUserInfoKey
    ]

    public init?(notification: Foundation.Notification) {
        guard let type = ApplicationEventType(notificationName: notification.name) else {
            return nil
        }

        self.type = type

        if
            let key = Swift.type(of: self).notificationValueKeys[notification.name],
            let value = notification.userInfo?[key] {

            self.value = value

        } else {

            self.value = nil
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

    fileprivate lazy var nc: NotificationCenter = NotificationCenter.default

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
