//
//  PostStruct.swift
//  KonaBot
//
//  Created by Alex Ling on 10/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

struct Post {
	let postUrl : String
	let previewUrl : String
	let url : String
	let heightOverWidth : CGFloat
	let tags : [String]
	let score : Int
	let rating : String
	let author : String
	let created_at : Int
}

struct ParsedPost {
	let url : String
	let tags : [String]
	let time : Int
	let author : String
	let score : String
	let rating : String
}
