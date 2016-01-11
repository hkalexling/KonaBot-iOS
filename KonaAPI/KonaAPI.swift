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

protocol KonaAPIDelegate {
	func konaAPIDidGetPosts(ary : [Post])
}

class KonaAPI: NSObject {
	
	private let manager = AFHTTPSessionManager()
	private var r18 : Bool = false
	private var delegate : KonaAPIDelegate?
	
	private var finished : Bool = true
	
	var postAry : [Post] = []
	
	init(r18 : Bool, delegate : KonaAPIDelegate){
		self.r18 = r18
		self.delegate = delegate
	}
	
	func getPost(limit : Int?, page : Int?, tag : String?){
		
		var parameters : [String : String] = [:]
		if let _limit = limit {
			parameters["limit"] = "\(_limit)"
		}
		if let _page = page {
			parameters["page"] = "\(_page)"
		}
		if let _tag = tag {
			parameters["tags"] = "\(_tag)"
		}
		manager.POST("http://konachan.net/post.json", parameters: parameters, progress : nil, success: {(task, response) in
			for post in response as! [NSDictionary] {
				let rating : String = post["rating"] as! String
				if !self.r18 && rating != "s" {
					continue
				}
				let id : Int = post["id"] as! Int
				let previewUrl : String = post["preview_url"] as! String
				let url : String = post["jpeg_url"] as! String
				let heightOverWidth = (post["height"] as! CGFloat)/(post["width"] as! CGFloat)
				let postTags : [String] = (post["tags"] as! String).componentsSeparatedByString(" ")
				let postObj = Post(postUrl : "http://konachan.net/post/show/\(id)", previewUrl: previewUrl, url: url, heightOverWidth: heightOverWidth, tags: postTags)
				self.postAry.append(postObj)
			}
			self.delegate?.konaAPIDidGetPosts(self.postAry)
			self.postAry = []
			//self.finished = true
			}, failure: {(task, error) in
				print (error.localizedDescription)
		})
	}
}
