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
		super.init(frame: CGRect(x: 0, y: 0, width: 16, height: 24))
		self.backgroundColor = UIColor.clear
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

    override func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(red: self.color.components.red, green: self.color.components.green, blue: self.color.components.blue, alpha: self.color.components.alpha)
		
		context?.move(to: CGPoint(x: 4, y: 0))
		context?.addLine(to: CGPoint(x: 4, y: 0))
		context?.addLine(to: CGPoint(x: 16, y: 12))
		context?.addLine(to: CGPoint(x: 4, y: 24))
		context?.addLine(to: CGPoint(x: 2, y: 22))
		context?.addLine(to: CGPoint(x: 12.5, y: 12))
		context?.addLine(to: CGPoint(x: 2, y: 2))
		context?.addLine(to: CGPoint(x: 4, y: 0))
		context?.fillPath()
    }
}
