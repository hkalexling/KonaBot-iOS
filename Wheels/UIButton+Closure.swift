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

typealias ButtonActionBlock = () -> Void

class ActionBlockWrapper : NSObject {
	var block : ButtonActionBlock
	init(block: @escaping ButtonActionBlock) {
		self.block = block
	}
}
