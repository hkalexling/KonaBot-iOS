//
//  CKManager.swift
//  KonaBot
//
//  Created by Alex Ling on 14/3/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit
import CloudKit

class CKManager: NSObject {
	
	class func addFavorited(postID : String) {
		if !CKManager.icloudAvaiable() {
			print ("iCloud Not Avaiable")
			return
		}
		let record = CKRecord(recordType: "FavoritedImage")
		record.setValue(postID, forKey: "postID")
		print ("uploading")
		CKContainer.defaultContainer().privateCloudDatabase.saveRecord(record, completionHandler: {(record, error) in
			print ("record: \(record)")
			print ("error: \(error)")
		})
	}
	
	class func addFavoritedWithUrl(urlString : String) {
		if let id = urlString.componentsSeparatedByString("/").last {
			CKManager.addFavorited(id)
		}
		else{
			print ("invalid url provided")
		}
	}
	
	class func removeFavorited(postID : String) {
		if !CKManager.icloudAvaiable() {
			print ("iCloud Not Avaiable")
			return
		}
		let predicate = NSPredicate(format: "postID == %@", postID)
		let query = CKQuery(recordType: "FavoritedImage", predicate: predicate)
		CKContainer.defaultContainer().privateCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: {(records, error) in
			if records != nil {
				if records!.count == 1 {
					let id = records![0].recordID
					CKContainer.defaultContainer().privateCloudDatabase.deleteRecordWithID(id, completionHandler: {(id, error) in
						if error != nil {
							print (error!)
						}
						else{
							print ("deleted")
						}
					})
				}
			}
			if error != nil {
				print (error!)
			}
		})
	}
	
	class func removeFavoritedWithUrl(urlString : String) {
		if let id = urlString.componentsSeparatedByString("/").last {
			CKManager.removeFavorited(id)
		}
		else{
			print ("invalid url provided")
		}
	}
	
	class func checkNewFavorited() {
		if !CKManager.icloudAvaiable() {
			print ("iCloud Not Avaiable")
			return
		}
		let favoriteList = Yuno().favoriteList()
		let postIDList = favoriteList.map({$0.componentsSeparatedByString("/").last}).filter({$0 != nil}).map({$0!})
		let predicate = NSPredicate(format: "NOT (postID IN %@)", postIDList)
		let query = CKQuery(recordType: "FavoritedImage", predicate: predicate)
		print ("checking favorited images from other devices")
		CKContainer.defaultContainer().privateCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: {(records, error) in
			if error != nil {
				print (error!)
			}
			if records != nil {
				let ids : [String] = records!.map({$0.valueForKey("postID")}).filter({$0 != nil}).map({($0! as! String)})
				let distinctIDs : [String] = Array(Set(ids))
				print ("found \(distinctIDs.count) new favorited images")
				for id in distinctIDs {
					print (id)
				}
			}
		})
	}
	
	class func icloudAvaiable() -> Bool {
		return NSFileManager.defaultManager().ubiquityIdentityToken != nil
	}
}
