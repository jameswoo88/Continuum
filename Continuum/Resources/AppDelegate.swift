//
//  AppDelegate.swift
//  Continuum
//
//  Created by DevMountain on 2/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkAccountStatus { success in
            let fetchedUserStatement = success ? "Successfully retrieved a logged in user" : "Failed to retrieve a loagged in user"
            print(fetchedUserStatement)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                return
            }
            
            success ? print("Successfully authorizaed to send push notification") : print("Push notification denied by the user")
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
                
        return true
    }
    
    func checkAccountStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { status, error in
            if let error = error {
                print("Error in \(#function) : On Line \(#line) : \(error.localizedDescription) \n---\n \(error)")
                completion(false); return
            }
            
            DispatchQueue.main.async {
                let tabBarController = self.window?.rootViewController
                let errorMessage = "Sign into iCloud in Settings"
                switch status {
                case .available:
                    completion(true)
                case .couldNotDetermine:
                    tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "There was an unknown error fetching your iCloud Account")
                    completion(false)
                case .restricted:
                    tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "Your iCloud account is restricted")
                    completion(false)
                case .noAccount:
                    tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "No account found")
                    completion(false)
                @unknown default:
                    tabBarController?.presentSimpleAlertWith(title: errorMessage, message: "Unkown error")
                    completion(false)
                }
            }
        }
    }//end of func
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
        
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0 //JCHUN - badge count does not reset to 0...
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

