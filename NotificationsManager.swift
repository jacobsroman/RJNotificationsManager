//
//  NotificationsManager.swift
//  DLP-Core
//
//  Created by Ra Man on 27.07.17.
//  Copyright © 2017 CEIT. All rights reserved.
//

import UIKit


protocol CustomNotificationHandler: AnyObject {
    func handleCustomNotification(_ someString:String)
}


enum Notifications: String, NotificationName {
    case CustomNotification
}

protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

class NotificationsManager: NSObject {
    
    static let shared = NotificationsManager()
    
    var observers = [Dictionary<String, AnyObject>]()
    
    func isObserver(_ observer:AnyObject) -> Bool {
        for obs in observers {
            if let theObs = obs["observer"] {
                if theObs.isEqual(observer) {
                    return true
                }
            }
        }
        return false
    }
    
    func observerFor(subscriber:AnyObject) -> Dictionary<String, AnyObject>?{
        for obs in observers {
            if let theSub = obs["subscriber"] {
                if theSub.isEqual(subscriber) {
                    return obs
                }
            }
        }
        return nil
    }
    
    func unsubscribeFromNotifications(subscriber:AnyObject) {
        if let observer = self.observerFor(subscriber: subscriber) {
            if let theObserver = observer["observer"] as? NSObjectProtocol {
                NotificationCenter.default.removeObserver(theObserver)
            }
        }
    }
    
    func addObserver(observer:AnyObject, subscriber:AnyObject) {
        var observeDict = Dictionary<String, AnyObject>()
        observeDict["observer"] = observer
        observeDict["subscriber"] = subscriber
        if (!self.isObserver(observer)) {
            self.observers.append(observeDict)
        }
    }
    
    func subscribeForCustomNotification(_ subscriber:CustomNotificationHandler) {
        let observer = NotificationCenter.default.addObserver(forName: Notifications.ConfirmedRegistration.name, object: nil, queue: .main) { (notification) in
            if let someString = notification.userInfo?["someString"] as? String {
                subscriber.handleCustomNotification(someString)
            }
        }
        self.addObserver(observer: observer, subscriber: subscriber)
    }
    
    func postRegistrationConfirmNotification(someString:String) {
        NotificationCenter.default.post(name: Notifications.ConfirmedRegistration.name, object: self, userInfo: ["someString":someString])
    }
}
