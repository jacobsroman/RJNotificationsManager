//  NotificationsManager.swift
//  Created by jacobsroman on 27.07.17.


/*
 This is a sample Notification manager that can be used in any project
 
 If you suggest some improvements - I'll be glad to expand this functionality
 */

import Foundation

// MARK: - Protocols & extensions
/*
 Describe your own handlers with custom objects or ets.
 */
protocol CustomNotificationHandler: AnyObject {
    func handleCustomNotification(_ someString:String)
}

/*
 Describe notification types
 */
enum Notifications: String, NotificationName {
    case CustomNotification
}

// Protocol, needed to implement Notification types
// --
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
// --

// MARK: - Instance
// Singletone instance that implements all the managering of posting/subscribing for notifications
class NotificationsManager: NSObject {
    
    static let shared = NotificationsManager()
    
    // This variable holds all subscribers for unsubscribing
    var observers = [Dictionary<String, AnyObject>]()
    
    // Helpfull functions
    // --
    private func isObserver(_ observer:AnyObject) -> Bool {
        for obs in observers {
            if let theObs = obs["observer"] {
                if theObs.isEqual(observer) {
                    return true
                }
            }
        }
        return false
    }
    
    private func observerFor(subscriber:AnyObject) -> Dictionary<String, AnyObject>?{
        for obs in observers {
            if let theSub = obs["subscriber"] {
                if theSub.isEqual(subscriber) {
                    return obs
                }
            }
        }
        return nil
    }
    
    private func addObserver(observer:AnyObject, subscriber:AnyObject) {
        var observeDict = Dictionary<String, AnyObject>()
        observeDict["observer"] = observer
        observeDict["subscriber"] = subscriber
        if (!self.isObserver(observer)) {
            self.observers.append(observeDict)
        }
    }
    // --
    
    // MARK: - Main functions
    func unsubscribeFromNotifications(subscriber:AnyObject) {
        if let observer = self.observerFor(subscriber: subscriber) {
            if let theObserver = observer["observer"] as? NSObjectProtocol {
                NotificationCenter.default.removeObserver(theObserver)
            }
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
