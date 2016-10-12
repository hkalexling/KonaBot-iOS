//
//  KonaHTMLParser.swift
//  KonaBot
//
//  Created by Alex Ling on 11/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit
import Kanna
import AFNetworking

protocol KonaHTMLParserDelegate {
	func konaHTMLParserFinishedParsing(_ parsedPost : ParsedPost)
}

protocol KonaHTMLParserTagsDelegate {
	func konaHTMLParserFinishedParsing(_ tags : [String])
}

extension XPathObject {
	var count : Int {
		get {
			var count_ = 0
			for _ in self {
				count_ += 1
			}
			return count_
		}
	}
	var last : XMLElement? {
		get {
			var last_ : XMLElement? = nil
			for ele in self {
				last_ = ele
			}
			return last_
		}
	}
}

//Some data such as comments of a post can not be accessed using API, so I have to parse the HTML and get the information I need
class KonaHTMLParser: NSObject {
	
	fileprivate var delegate : KonaHTMLParserDelegate!
	fileprivate var tagDelegate : KonaHTMLParserTagsDelegate!
	fileprivate var errorDelegate : KonaAPIErrorDelegate!
	fileprivate var parsedPost : ParsedPost!
	
	init(delegate : KonaHTMLParserDelegate, errorDelegate : KonaAPIErrorDelegate){
		self.delegate = delegate
		self.errorDelegate = errorDelegate
	}
	
	init(delegate : KonaHTMLParserTagsDelegate, errorDelegate : KonaAPIErrorDelegate){
		self.tagDelegate = delegate
		self.errorDelegate = errorDelegate
	}
	
	func getPostInformation (_ postUrl : String) {
		print ("parsing \(postUrl)")
		let successBlock : ((_ html : String) -> Void) = {(html) in
			self.parseHTML(html)
		}
		self.getHTML(postUrl, successBlock: successBlock)
	}
	
	fileprivate func getHTML (_ url : String, successBlock : @escaping ((_ html : String) -> Void)) {
		let manager = AFHTTPSessionManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		manager.get(url, parameters: nil, progress: nil, success: {(task, response) in
			let html = NSString(data: response as! NSData as Data, encoding: String.Encoding.ascii.rawValue)! as String
			successBlock(html)
			}, failure: {(operation, error) -> Void in
				self.errorDelegate.konaAPIGotError(error as NSError)
				print ("Error : \(error)")
		})
	}
	
	fileprivate func parseHTML (_ html : String) {
		
		let failBlock : ((Void) -> Void) = {
			self.triggerErrorFrom("Failed to parse page")
		}
		
		let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8)!
		
		var imageUrl = ""
		var tags : [String] = []
		var time : Int = 0
		var author : String = ""
		var rating : String = ""
		var score : String = ""
		
		let divAry = doc.at_css("body")?.at_css("div#content")?.at_css("div#post-view")?.at_css("div#right-col.content")?.css("div")
		
		if divAry == nil {
			failBlock()
			return
		}
		
		for div in divAry! {
			if let img = div.at_css("img#image.image") {
				if let src = img["src"] {
					imageUrl = src
				}
			}
		}
		
		if imageUrl == "" {
			failBlock()
			return
		}
		
		let sideBar = doc.at_css("body")?.at_css("div#content")?.at_css("div#post-view")?.at_css("div.sidebar")
		
		if sideBar == nil {
			failBlock()
			return
		}
		
		if let sideBar = sideBar?.at_css("ul#tag-sidebar") {
			let tagLis = sideBar.css("li.tag-link")
			for ls in tagLis {
				if let tag = ls["data-name"] {
					tags.append(tag)
				}
			}
		}
		
		let stats = sideBar?.at_css("div#stats.vote-container")
		let lis = stats?.at_css("ul")!.css("li")
		
		if lis == nil {
			failBlock()
			return
		}
		
		let hasSource = lis!.count == 7
		
		time = lis![1].at_css("a")!["title"]!.konaChanTimeToUnixTime()
		author = lis![1].css("a").count > 1 ? lis![1].css("a")[1].text! : "Unknown"
		rating = lis![hasSource ? 4 : 3].text!.components(separatedBy: " ")[1].localized
		score = lis![hasSource ? 5 : 4].at_css("span")!.text!
		
		if !Yuno.r18 {
			tags = KonaAPI.r18Filter(tags)
		}
		
		self.parsedPost = ParsedPost(url: imageUrl, tags: tags, time: time, author: author, score: score, rating: rating)
		self.delegate.konaHTMLParserFinishedParsing(self.parsedPost)
	}
	
	fileprivate func parseSuggestedTagsFromHTML (_ html : String) -> [String] {
		var suggestedTag : [String] = []
		if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
			let ulList = doc.css("ul#post-list-posts")
			if ulList.count == 0 {
				for div in doc.css("div"){
					if (div.className != nil) {
						if (div.className! == "status-notice"){
							for span in div.css("span"){
								let a = span.at_css("a")!
								suggestedTag.append(a.text!)
							}
						}
					}
				}
			}
		}
		if !Yuno.r18 {
			suggestedTag = KonaAPI.r18Filter(suggestedTag)
		}
		return suggestedTag
	}
	
	func getSuggestedTagsFromEmptyTag (_ tag : String) {
		let successBlock = {(html : String) in
			let tags = self.parseSuggestedTagsFromHTML(html)
			self.tagDelegate.konaHTMLParserFinishedParsing(tags)
		}
		self.getHTML("\(Yuno().baseUrl())/post?tags=\(tag)", successBlock: successBlock)
	}
	
	fileprivate func triggerErrorFrom(_ string: String) {
		let userInfo : [NSObject : String] = [NSLocalizedDescriptionKey as NSObject : string]
		let error = NSError(domain: "com.hkalexling.konabot", code: 200, userInfo: userInfo)
		self.errorDelegate.konaAPIGotError(error)
	}
}

extension String {
	func konaChanTimeToUnixTime() -> Int {
		var ary = self.components(separatedBy: " ")
		ary = ary.filter({element in
			element != ""
		})
		let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
		
		let year : Int = (ary.last! as NSString).integerValue
		let month : Int = months.index(of: ary[1])! + 1
		let day : Int = (ary[2] as NSString).integerValue
		let timeAry = ary[3].components(separatedBy: ":")
		let hour = (timeAry[0] as NSString).integerValue
		let minute = (timeAry[1] as NSString).integerValue
		let second = (timeAry[2] as NSString).integerValue
		
		var component = DateComponents()
		component.setValue(year, for: .year)
		component.setValue(month, for: .month)
		component.setValue(day, for: .day)
		component.setValue(hour, for: .hour)
		component.setValue(minute, for: .minute)
		component.setValue(second, for: .second)
		
		component.calendar = Calendar.current
		component.calendar?.timeZone = TimeZone(secondsFromGMT: 0)!
		
		return Int((component as NSDateComponents).date!.timeIntervalSince1970)
	}
}
