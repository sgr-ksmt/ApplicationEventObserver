# ApplicationEventObserver

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/ApplicationEventObserver.svg?style=flat)](http://cocoapods.org/pods/ApplicationEventObserver)
[![License](https://img.shields.io/cocoapods/l/ApplicationEventObserver.svg?style=flat)](http://cocoapods.org/pods/ApplicationEventObserver)
[![Platform](https://img.shields.io/cocoapods/p/ApplicationEventObserver.svg?style=flat)](http://cocoapods.org/pods/ApplicationEventObserver)

Application event notification (e.g. UIApplicationDidBecomeActiveNotification) handling in Swift.

## :tada:Features
- You don't have to use `NSNotificationCenter`.
- You can catch event(s) only you want to.
- You can do `subscribe/resume/suspend/dispose` at anytime.

## :pencil2:How to use

First, you create `ApplicationEventObserver` instance.<br />
The instance obverves UIApplication events untill release(deinit).<br />
(e.g.)

```swift
class ViewController: UIViewController {
    private lazy var appEventObserver = ApplicationEventObserver()
    ...
}
```

Second, subscribe event(s) you want to catch.<br />
For example, you want to catch `UIApplicationDidBecomeActive` event,
check returned value `event`'s type in handler(closure).

```swift
func viewDidLoad() {
    super.viewDidLoad()
    appEventObserver.subscribe() { event in
        switch event.type {
        case .DidBecomeActive:
            print(event.type.notificationName)
        default:
            break
        }
    }
}
```

Also, you can suspend/resume anytime. <br />
If instance's state is suspended, stop observing all events until call `resume()` <br />
(e.g.)

```swift
func showPopup() {
    appEventObserver.suspend()
}
...
func closePopup() {
    appEventObserver.resume()
}
```

### Specs

#### ApplicationEvent (struct)
`ApplicationEvent` has two parameters.
- type : `ApplicationEventType`
- value : `NSNotification` instance's userInfo value if the instance has. Provide as `AnyObject?`

## :pushpin:Example

### Before (Use NSNotificationCenter)

```swift
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "notified:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "notified:",
            name: UIApplicationWillChangeStatusBarFrameNotification,
            object: nil
        )
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

private extension ViewController {
    @objc private func notified(notification: NSNotification) {
        switch notification.name {
        case UIApplicationDidBecomeActiveNotification:
            print(notification.name)
        case UIApplicationWillChangeStatusBarFrameNotification:
            let rect = notification.userInfo?[UIApplicationStatusBarFrameUserInfoKey]
            print(notification.name,rect)
        default:
            break
        }
    }
}
```

### After (Use ApplicationEventObserver)

```swift
import UIKit

import ApplicationEventObserver

class ViewController: UIViewController {

    private lazy var appEventObserver = ApplicationEventObserver()

    override func viewDidLoad() {
        super.viewDidLoad()

        appEventObserver.subscribe() { event in
            switch event.type {
            case .DidBecomeActive, .WillResignActive:
                print(event.type.notificationName)
            case .WillChangeStatusBarFrame:
                if let v = event.value {
                    print(event.type.notificationName, v)
                }
            default:
                break
            }
        }

    }

}
```

So simple !!:star:

## Supported Events
- Supported events list below:

| Notification Name                                         | ApplicationEventType              |
|:----------------------------------------------------------|:----------------------------------|
| UIApplicationDidFinishLaunchingNotification               | .DidFinishLaunching               |
| UIApplicationWillEnterForegroundNotification              | .WillEnterForeground              |
| UIApplicationDidEnterBackgroundNotification               | .DidEnterBackground,              |
| UIApplicationWillResignActiveNotification                 | .WillResignActive,                |
| UIApplicationDidBecomeActiveNotification                  | .DidBecomeActive,                 |
| UIApplicationDidReceiveMemoryWarningNotification          | .DidReceiveMemoryWarning,         |
| UIApplicationWillTerminateNotification                    | .WillTerminate,                   |
| UIApplicationSignificantTimeChangeNotification            | .SignificantTimeChange,           |
| UIApplicationWillChangeStatusBarOrientationNotification   | .WillChangeStatusBarOrientation,  |
| UIApplicationDidChangeStatusBarOrientationNotification    | .DidChangeStatusBarOrientation,   |
| UIApplicationWillChangeStatusBarFrameNotification         | .WillChangeStatusBarFrame         |
| UIApplicationDidChangeStatusBarFrameNotification          | .DidChangeStatusBarFrame          |
| UIApplicationBackgroundRefreshStatusDidChangeNotification | .BackgroundRefreshStatusDidChange |

### Options

`UIApplicationWillChangeStatusBarOrientationNotification` <br />
`UIApplicationDidChangeStatusBarOrientationNotification` <br />
→ You can get orientation value.

`UIApplicationWillChangeStatusBarOrientationNotification` <br />
`UIApplicationDidChangeStatusBarOrientationNotification` <br />
→ You can get rect value.

## Requirements
- iOS 8.0+
- Xcode 7.0+(Swift 2+)

## Installation and Setup

### With Carthage
- Just add the following line to your *Cartfile*:

```ruby
github "sgr-ksmt/ApplicationEventObserver"
```

- Run `carthage update` on Terminal.
- Add the framework as described. Details: [Carthage README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

### With CocoaPods
Just add the following line to your Podfile:

```ruby
pod 'ApplicationEventObserver'
```

- Run `pod install` on Terminal.