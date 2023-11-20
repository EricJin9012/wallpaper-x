//
//  AppDelegate.swift
//  Wallpapers X
//
//  Created by DanJin on 2019/11/28.
//  Copyright © 2019 sarwatshah. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMobileAds
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

//        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
//            for purchase in purchases {
//                switch purchase.transaction.transactionState {
//                case .purchased, .restored:
//                    if purchase.needsFinishTransaction {
//                        // Deliver content from server, then:
//                        SwiftyStoreKit.finishTransaction(purchase.transaction)
//                    }
//                    // Unlock content
//                case .failed, .purchasing, .deferred:
//                    break // do nothing
//                }
//            }
//        }
//        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
//        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//            switch result {
//            case .success(let receipt):
//                let productId = "com.sarwatshah.wallpapersx.main.weekly"
//                // Verify the purchase of a Subscription
//                let purchaseResult = SwiftyStoreKit.verifySubscription(
//                    ofType: .autoRenewable, // or .nonRenewing (see below)
//                    productId: productId,
//                    inReceipt: receipt)
//
//                switch purchaseResult {
//                case .purchased(let expiryDate, let items):
//                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
//                    UserDefaults.standard.set(true, forKey: "isUserSubbed")
//                case .expired(let expiryDate, let items):
//                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
//                    UserDefaults.standard.set(false, forKey: "isUserSubbed")
//                case .notPurchased:
//                    print("The user has never purchased \(productId)")
//                    UserDefaults.standard.set(false, forKey: "isUserSubbed")
//                }
//
//            case .error(let error):
//                print("Receipt verification failed: \(error)")
//            }
//        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    @available(iOS 13.0, *)
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Wallpapers_X")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    @available(iOS 13.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

