//
//  AppDelegate.swift
//  BlueCap
//
//  Created by Troy Stribling on 6/6/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import BlueCapKit

struct BlueCapNotification {
    static let peripheralDisconnected   = "PeripheralDisconnected"
    static let didUpdateBeacon          = "DidUpdateBeacon"
    static let didBecomeActive          = "DidBecomeActive"
    static let didResignActive          = "DidResignActive"
}

enum AppError : Int {
    case rangingBeacons = 0
    case outOfRegion    = 1
}

struct BCAppError {
    static let domain = "BlueCapApp"
    static let rangingBeacons = NSError(domain:domain, code:AppError.rangingBeacons.rawValue, userInfo:[NSLocalizedDescriptionKey:"Ranging beacons"])
    static let outOfRegion = NSError(domain:domain, code:AppError.outOfRegion.rawValue, userInfo:[NSLocalizedDescriptionKey:"Out of region"])
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window : UIWindow?

    class func sharedApplication() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override init() {
        super.init()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        TISensorTagServiceProfiles.create()
        BLESIGGATTProfiles.create()
        GnosusProfiles.create()
        NordicProfiles.create()
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes:[UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories:nil))
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSUserDefaults.standardUserDefaults().synchronize()
        NSNotificationCenter.defaultCenter().postNotificationName(BlueCapNotification.didResignActive, object:nil)
        if CentralManager.sharedInstance.isScanning {
            CentralManager.sharedInstance.stopScanning()
            CentralManager.sharedInstance.disconnectAllPeripherals()
            CentralManager.sharedInstance.removeAllPeripherals()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        Notify.resetEventCount()
        NSNotificationCenter.defaultCenter().postNotificationName(BlueCapNotification.didBecomeActive, object:nil)
    }

    func applicationWillTerminate(application: UIApplication) {
         NSUserDefaults.standardUserDefaults().synchronize()
    }


}

