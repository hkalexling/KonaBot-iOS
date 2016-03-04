//
//  AppDelegate.swift
//  KonaBot
//
//  Created by Alex Ling on 30/10/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let yuno = Yuno()

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		self.yuno.deleteEntity("Preview")
		if NSUserDefaults.standardUserDefaults().boolForKey("optimize"){
			self.yuno.deleteEntity("Cache")
		}
		
		if NSUserDefaults.standardUserDefaults().objectForKey("optimize") == nil{
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "optimize")
		}
		
		if NSUserDefaults.standardUserDefaults().objectForKey("viewMode") == nil {
			NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "viewMode")
		}
		
		UITabBar.appearance().tintColor = UIColor.konaColor()
		UITabBar.appearance().barTintColor = UIColor.lighterThemeColor()
		UICollectionView.appearance().backgroundColor = UIColor.themeColor()
		UINavigationBar.appearance().barTintColor = UIColor.lighterThemeColor()
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.konaColor()]
		UINavigationBar.appearance().tintColor = UIColor.konaColor()
		UITableView.appearance().backgroundColor = UIColor.themeColor()
		UITableViewCell.appearance().backgroundColor = UIColor.lighterThemeColor()
		application.setStatusBarStyle(UIStatusBarStyle.styleAccordingToTheme(), animated: false)
		
		return true
	}
	
	@available(iOS 9.0, *)
	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		completionHandler( handleShortcut(shortcutItem) )
	}
	
	@available(iOS 9.0, *)
	func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
		var succeeded = false
		if( shortcutItem.type == "search" ) {
			succeeded = true
			
			NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "tabToSelect")
		}
		if( shortcutItem.type == "favorite" ) {
			succeeded = true
			
			NSUserDefaults.standardUserDefaults().setInteger(2, forKey: "tabToSelect")
		}
		return succeeded
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		self.yuno.deleteEntity("Preview")
		if NSUserDefaults.standardUserDefaults().boolForKey("optimize"){
			self.yuno.deleteEntity("Cache")
		}
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	// MARK: - Core Data stack
	
	lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		return urls[urls.count-1]
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("KonaBot.sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		return coordinator
	}()
	
	lazy var managedObjectContext: NSManagedObjectContext = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch {
				print (error)
			}
		}
	}

}

