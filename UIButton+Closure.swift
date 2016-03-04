//
//  UIButton+Closure.swift
//  KonaBot
//
//  Created by Alex Ling on 5/3/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import ObjectiveC
import UIKit

var ActionBlockKey: UInt8 = 0

// a type for our action block closure
typealias BlockButtonActionBlock = () -> Void

class ActionBlockWrapper : NSObject {
	var block : BlockButtonActionBlock
	init(block: BlockButtonActionBlock) {
		self.block = block
	}
}
