//
//  KonaAPI.swift
//  KonaBot
//
//  Created by Alex Ling on 10/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

/*
[author, frames_pending, created_at, id, file_size, file_url, frames_string, preview_url, creator_id, preview_height, actual_preview_height, jpeg_file_size, score, jpeg_width, jpeg_height, frames, sample_height, parent_id, is_held, source, change, frames_pending_string, height, status, sample_width, tags, jpeg_url, has_children, actual_preview_width, sample_file_size, preview_width, md5, is_shown_in_index, rating, sample_url, width]
*/

import UIKit
import AFNetworking

protocol KonaAPIPostDelegate {
	func konaAPIDidGetPost(_ ary : [Post])
}

protocol KonaAPITagDelegate {
	func konaAPIDidGetTag(_ ary : [String])
}

protocol KonaAPIErrorDelegate {
	func konaAPIGotError(_ error : Error)
}

private extension String {
	func toValidURL() -> String {
		// convert
		// 1. //blablabla
		// 2. blablabla
		// to http://blablabla
		
		if (self.hasPrefix("http://") || self.hasPrefix("https://")) {
			return self
		}
		else if (self.hasPrefix("//")) {
			return "http:\(self)"
		}
		else{
			return "http://\(self)"
		}
	}
}

class KonaAPI: NSObject {
	
	fileprivate let baseUrl = "http://konachan.com"
	
	fileprivate let manager = AFHTTPSessionManager()
	fileprivate var r18 : Bool = false
	
	fileprivate var postDelegate : KonaAPIPostDelegate?
	fileprivate var tagDelegate : KonaAPITagDelegate?
	fileprivate var errorDelegate : KonaAPIErrorDelegate?
	
	fileprivate var postAry : [Post] = []
	fileprivate var tagAry : [String] = []
	static let hiddenTags : [String] = ["nipples", "cleavage", "pussy", "nude" , "ass", "panties", "breasts", "porn"]
	
	init(r18 : Bool, delegate : KonaAPIPostDelegate, errorDelegate : KonaAPIErrorDelegate){
		self.r18 = r18
		self.postDelegate = delegate
		self.errorDelegate = errorDelegate
	}
	
	init(r18 : Bool, delegate : KonaAPITagDelegate, errorDelegate : KonaAPIErrorDelegate){
		self.r18 = r18
		self.tagDelegate = delegate
		self.errorDelegate = errorDelegate
	}
	
	func getPosts(_ limit : Int?, page : Int?, tag : String?){
		let parameters = self.parameterFactory(["limit" : limit as Optional<AnyObject>, "page" : page as Optional<AnyObject>, "tags" : tag as Optional<AnyObject>])
		let successBlock = {(task : URLSessionDataTask, response : Any?) in
			for post in response as! [NSDictionary] {
				var rating : String = post["rating"] as! String
				if !self.r18 && rating != "s" {
					continue
				}
				var _rating = ""
				switch rating{
					case "s":
					_rating = "Safe".localized
					case "q":
					_rating = "Questionable".localized
					case "e":
					_rating = "Explicit".localized
					default: break
				}
				rating = _rating
				let id : Int = post["id"] as! Int
				let previewUrl : String = (post["preview_url"] as! String).toValidURL()
				let url : String = (post["jpeg_url"] as! String).toValidURL()
				let heightOverWidth = (post["height"] as! CGFloat)/(post["width"] as! CGFloat)
				let postTags : [String] = (post["tags"] as! String).components(separatedBy: " ")
				let score : Int = post["score"] as! Int
				let author : String = post["author"] as! String
				let created_at : Int = post["created_at"] as! Int
				
				let postObj = Post(postUrl : self.baseUrl + "/post/show/\(id)", previewUrl: previewUrl, url: url, heightOverWidth: heightOverWidth, tags: postTags, score: score, rating: rating, author: author, created_at: created_at)
				self.postAry.append(postObj)
			}
			self.postDelegate?.konaAPIDidGetPost(self.postAry)
			self.postAry = []
		}
		self.makeHTTPRequest(true, url: self.baseUrl + "/post.json", parameters: parameters, successBlock: successBlock)
	}
	
	//Types:  General: 0, artist: 1, copyright: 3, character: 4
	//Order: date, count, name
	func getTags(_ limit : Int?, type : Int?, order : String?){
		let parameters = self.parameterFactory(["limit" : limit as Optional<AnyObject>, "type" : type as Optional<AnyObject>, "order" : order as Optional<AnyObject>])
		let successBlock = {(task : URLSessionDataTask, response : Any?) in
			for tag in response as! [NSDictionary]{
				let tagStr = tag.object(forKey: "name") as! String
				self.tagAry.append(tagStr)
			}
			if !self.r18 {
				self.tagAry = KonaAPI.r18Filter(self.tagAry)
			}
			self.tagDelegate?.konaAPIDidGetTag(self.tagAry)
			self.tagAry = []
		}
		self.makeHTTPRequest(false, url: self.baseUrl + "/tag.json", parameters: parameters as Any?, successBlock: successBlock)
	}
	
	func makeHTTPRequest(_ isPost : Bool, url : String, parameters : Any?, successBlock: ((URLSessionDataTask, Any?) -> Void)?){
		let errorBlock : ((URLSessionDataTask?, Error) -> Void) = {(task : URLSessionDataTask?, error : Error) in
			self.errorDelegate?.konaAPIGotError(error)
			print (error, terminator: "")
		}
		if isPost {
			self.manager.post(url, parameters: parameters, progress: nil, success: successBlock, failure: errorBlock)
		}
		else {
			self.manager.get(url, parameters: parameters, progress: nil, success: successBlock, failure: errorBlock)
		}
	}
	
	func parameterFactory(_ rawParameters : [String : AnyObject?]) -> [String : String] {
		var parameters : [String : String] = [:]
		for (key, value) in rawParameters {
			if let unwrapValue = value {
				parameters[key] = unwrapValue is String ? unwrapValue as! String : "\(unwrapValue)"
			}
		}
		return parameters
	}
	
	class func r18Filter (_ tags : [String]) -> [String] {
		var safeTags : [String] = []
		tagLoop: for tag in tags {
			for hidden in KonaAPI.hiddenTags {
				if tag.range(of: hidden) != nil {
					continue tagLoop
				}
			}
			safeTags.append(tag)
		}
		return safeTags
	}
}
