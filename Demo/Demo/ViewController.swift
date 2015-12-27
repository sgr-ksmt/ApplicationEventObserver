//
//  ViewController.swift
//  Demo
//
//  Created by Suguru Kishimoto on 2016/01/20.
//
//

import UIKit

class ViewController: UIViewController {

    private lazy var observer = ApplicationEventObserver()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        observer.subscribe() { event in
            switch event.type {
            case .DidBecomeActive, .WillResignActive:
                print(event.type.notificationName)
            case .WillChangeStatusBarFrame:
                if let v = event.value {
                    print(event.type.notificationName)
                    print(v)
                }
            default: break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

