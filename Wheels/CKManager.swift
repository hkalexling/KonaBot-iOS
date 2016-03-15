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
	
	var icloudAvaiable = false
	
	override init(){
		super.init()
		self.icloudAvaiable = NSFileManager.defaultManager().ubiquityIdentityToken != nil
	}
	
	func addFavorited(postID : String) {
		if !self.icloudAvaiable {
			self.CKprint ("iCloud Not Avaiable")
			return
		}
		let record = CKRecord(recordType: "FavoritedImage")
		record.setValue(postID, forKey: "postID")
		self.CKprint ("uploading")
		CKContainer.defaultContainer().privateCloudDatabase.saveRecord(record, completionHandler: self.CKHandler({(record_) in
			self.CKprint(record_ as! CKRecord)
		}))
	}
	
	func addFavoritedWithUrl(urlString : String) {
		if let id = self.urlToID(urlString) {
			self.addFavorited(id)
		}
	}
	
	func removeFavorited(postID : String) {
		if !self.icloudAvaiable {
			self.CKprint ("iCloud Not Avaiable")
			return
		}
		let predicate = NSPredicate(format: "postID == %@", postID)
		let query = CKQuery(recordType: "FavoritedImage", predicate: predicate)
		CKContainer.defaultContainer().privateCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: self.CKHandler({(records_) in
			let records = records_ as! [CKRecord]
			if records.count == 1 {
				let id = records[0].recordID
				CKContainer.defaultContainer().privateCloudDatabase.deleteRecordWithID(id, completionHandler: self.CKHandler({(_) in
					print ("deleted")
				}))
			}
		}))
	}
	
	func removeFavoritedWithUrl(urlString : String) {
		if let id = self.urlToID(urlString) {
			self.removeFavorited(id)
		}
	}
	
	func checkNewFavorited() {
		if !self.icloudAvaiable {
			self.CKprint ("iCloud Not Avaiable")
			return
		}
		let favoriteList = Yuno().favoriteList()
		let postIDList = favoriteList.map({$0.componentsSeparatedByString("/").last}).filter({$0 != nil}).map({$0!})
		let predicate = NSPredicate(format: "NOT (postID IN %@)", postIDList)
		let query = CKQuery(recordType: "FavoritedImage", predicate: predicate)
		self.CKprint ("checking favorited images from other devices")
		CKContainer.defaultContainer().privateCloudDatabase.performQuery(query, inZoneWithID: nil, completionHandler: self.CKHandler({(records_) in
			let records = records_ as! [CKRecord]
			let ids : [String] = records.map({$0.valueForKey("postID")}).filter({$0 != nil}).map({($0! as! String)})
			let distinctIDs : [String] = Array(Set(ids))
			self.CKprint ("found \(distinctIDs.count) new favorited images")
			for id in distinctIDs {
				self.CKprint (id)
			}
		}))
	}
	
	private func urlToID(urlString : String) -> String? {
		if let id = urlString.componentsSeparatedByString("/").last {
			return id
		}
		self.CKprint ("invalid url provided")
		return nil
	}
	
	private func CKprint(arg : Any) {
		print ("CKManager: \(arg)")
	}
	
	private func CKHandler(recordOrIDHandler: ((recordOrID : Any) -> Void)?) -> (Any?, NSError?) -> Void {
		return {(result, error) in
			if error != nil {
				self.CKprint(error!)
			}
			if result != nil {
				if let handler = recordOrIDHandler {
					handler(recordOrID: result!)
				}
			}
		}
	}
}
