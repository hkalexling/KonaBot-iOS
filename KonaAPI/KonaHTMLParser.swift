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

//Some data such as comments of a post can not be accessed using API, so I have to parse the HTML and get the information I need
class KonaHTMLParser: NSObject {
	
	func getPostInformation (postUrl : String) {
		self.parseHTML(self.getPostHTML(postUrl))
	}
	
	private func getPostHTML (url : String) -> String {
		var html = ""
		let manager = AFHTTPSessionManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		manager.GET(url, parameters: nil, progress: nil,
			success: {(operation, responseObject) -> Void in
				
				html = NSString(data: responseObject as! NSData, encoding: NSASCIIStringEncoding)! as String
				
			}, failure: {(operation, error) -> Void in
				print ("Error : \(error)")
		})
		return html
	}
	
	private func parseHTML (html : String) {
		
	}
}
