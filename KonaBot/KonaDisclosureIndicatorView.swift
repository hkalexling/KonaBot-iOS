//
//  KonaDisclosureIndicatorView.swift
//  KonaBot
//
//  Created by Alex Ling on 30/12/2015.
//	Modified from http://pastebin.com/xgReAeWc
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class KonaDisclosureIndicatorView: UIView {
	
	var color = UIColor.konaColor()
	
	init(color : UIColor){
		self.color = color
		super.init(frame: CGRectMake(0, 0, 16, 24))
		self.backgroundColor = UIColor.clearColor()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

    override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		CGContextSetRGBFillColor(context, self.color.components.red, self.color.components.green, self.color.components.blue, self.color.components.alpha)
		
		CGContextMoveToPoint(context, 4, 0)
		CGContextAddLineToPoint(context, 4, 0)
		CGContextAddLineToPoint(context, 16, 12)
		CGContextAddLineToPoint(context, 4, 24)
		CGContextAddLineToPoint(context, 2, 22)
		CGContextAddLineToPoint(context, 12.5, 12)
		CGContextAddLineToPoint(context, 2, 2)
		CGContextAddLineToPoint(context, 4, 0)
		CGContextFillPath(context)
    }
}
