//
//  CKManager.swift
//  KonaBot
//
//  Created by Alex Ling on 14/3/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit
import CloudKit

protocol CKManagerNewFavDelegate {
	func CKManagerDidFoundNewFavPost(_ ids : [String])
}

class CKManager: NSObject {
	
	var icloudAvaiable = false
	var favDelegate : CKManagerNewFavDelegate?
	
	override init(){
		super.init()
		self.icloudAvaiable = FileManager.default.ubiquityIdentityToken != nil
	}
	
	func addFavorited(_ postID : String) {
		if !self.icloudAvaiable {
			self.CKprint ("iCloud Not Avaiable")
			return
		}
		let record = CKRecord(recordType: "FavoritedImage")
		record.setValue(postID, forKey: "postID")
		self.CKprint ("uploading")
		CKContainer.default().privateCloudDatabase.save(record, completionHandler: self.CKHandler({(record) in
			self.CKprint(record)
		}))
	}
	
	func addFavoritedWithUrl(_ urlString : String) {
		if let id = self.urlToID(urlString) {
			self.addFavorited(id)
		}
	}
	
	func removeFavorited(_ postID : String) {
		if !self.icloudAvaiable {
			self.CKprint ("iCloud Not Avaiable")
			return
		}
		let predicate = Predicate(format: "postID == %@", postID)
		let query = CKQuery(recordType: "FavoritedImage", predicate: predicate)
		CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: self.CKHandler({(records) in
			if records.count == 1 {
				let id = records[0].recordID
				CKContainer.default().privateCloudDatabase.delete(withRecordID: id, completionHandler: self.CKHandler({(_) in
					self.CKprint ("deleted")
				}))
			}
		}))
	}
	
	func removeFavoritedWithUrl(_ urlString : String) {
		if let id = self.urlToID(urlString) {
			self.removeFavorited(id)
		}
	}
	
	func checkNewFavorited() {
		if !self.icloudAvaiable {
			self.CKprint ("iCloud Not Avaiable")
			return
		}
		var favoriteList = Yuno().favoriteList()
		if favoriteList.count == 0 {
			//passing empty `postIDList` into the query will cause internal server error
			favoriteList.append("")
		}
		let favListWithoutLastSlash : [String] = favoriteList.map({fav in
			if fav.hasSuffix("/") {
				return String(fav.characters.dropLast())
			}
			return fav
		})
		let postIDList = favListWithoutLastSlash.map({$0.components(separatedBy: "/").last}).filter({$0 != nil}).map({$0!})
		let predicate = Predicate(format: "NOT (postID IN %@)", postIDList)
		let query = CKQuery(recordType: "FavoritedImage", predicate: predicate)
		self.CKprint ("checking favorited images from other devices")
		CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: self.CKHandler({(records) in
			let ids : [String] = records.map({$0.value(forKey: "postID")}).filter({$0 != nil}).map({($0! as! String)})
			let distinctIDs : [String] = Array(Set(ids))
			self.CKprint ("found \(distinctIDs.count) new favorited images")
			for id in distinctIDs {
				self.CKprint (id)
			}
			self.favDelegate?.CKManagerDidFoundNewFavPost(distinctIDs)
		}))
	}
	
	private func urlToID(_ urlString : String) -> String? {
		let urlStrWithoutLastSlash = urlString.hasSuffix("/") ? String(urlString.characters.dropLast()) : urlString
		if let id = urlStrWithoutLastSlash.components(separatedBy: "/").last {
			return id
		}
		self.CKprint ("invalid url provided")
		return nil
	}
	
	private func CKprint(_ arg : Any) {
		print ("CKManager: \(arg)")
	}
	
	private func CKHandler<A>(_ recordOrIDHandler: ((recordOrID : A) -> Void)?) -> (A?, NSError?) -> Void {
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
