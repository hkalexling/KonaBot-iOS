//
//  AWProgressIndicatorView.swift
//  KonaBot
//
//  Created by Alex Ling on 26/2/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class AWProgressIndicatorView: UIImageView {
	
	var color : UIColor!
	var textColor : UIColor!
	var bgColor : UIColor!
	var width : CGFloat!
	var radius : CGFloat!
	var font : UIFont!
	var showText : Bool!
	
	var text : UILabel!
	var spinTimer : NSTimer?
	var angle : CGFloat!
	var spinSpeed : CGFloat!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	init(color : UIColor, textColor : UIColor, bgColor : UIColor, showText : Bool, width : CGFloat, radius : CGFloat, font : UIFont){
		self.color = color
		self.textColor = textColor
		self.bgColor = bgColor
		self.showText = showText
		self.width = width
		self.radius = radius
		self.font = font
		
		self.text = UILabel(frame: CGRectMake(0, 0, self.radius * 2, self.radius * 2))
		self.text.textAlignment = .Center
		self.text.textColor = self.textColor
		self.text.font = self.font
		self.text.hidden = !self.showText
		
		super.init(frame: CGRectMake(0, 0, self.radius * 2, self.radius * 2))
		self.addSubview(self.text)
	}
	
	func updateProgress(progress : CGFloat) {
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(2 * self.radius + self.width, 2 * self.radius + self.width), false, 0)
		
		let bgPath = UIBezierPath(arcCenter: CGPointMake(self.radius + self.width/2, self.radius + self.width/2), radius: self.radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
		bgPath.lineWidth = self.width
		self.bgColor.setStroke()
		bgPath.stroke()
		
		let percentagePath = UIBezierPath(arcCenter: CGPointMake(self.radius + self.width/2, self.radius + self.width/2), radius: self.radius, startAngle: CGFloat(-0.5 * M_PI), endAngle: self.progressToRadian(progress), clockwise: true)
		percentagePath.lineWidth = self.width
		self.color.setStroke()
		percentagePath.stroke()
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		UIView.transitionWithView(self, duration: 0.1, options: [.TransitionCrossDissolve], animations: {self.image = image}, completion: nil)
		UIView.transitionWithView(self.text, duration: 0.1, options: [.TransitionCrossDissolve], animations: {self.text.text = "\(Int(progress * 100))%"}, completion: nil)
	}
	
	func startSpin(speed : CGFloat) {
		self.angle = 0
		self.spinSpeed = speed
		self.spinTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(AWProgressIndicatorView.updateSpin), userInfo: nil, repeats: true)
	}
	
	func stopSpin() {
		self.spinTimer?.invalidate()
		self.spinTimer = nil
	}
	
	func updateSpin() {
		self.angle = self.spinSpeed + self.angle
		self.spin()
	}
	
	func spin() {
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(2 * self.radius + self.width, 2 * self.radius + self.width), false, 0)
		
		let bgPath = UIBezierPath(arcCenter: CGPointMake(self.radius + self.width/2, self.radius + self.width/2), radius: self.radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
		bgPath.lineWidth = self.width
		self.bgColor.setStroke()
		bgPath.stroke()
		
		let percentagePath = UIBezierPath(arcCenter: CGPointMake(self.radius + self.width/2, self.radius + self.width/2), radius: self.radius, startAngle: self.angle, endAngle: self.angle + CGFloat(M_PI/3), clockwise: true)
		percentagePath.lineWidth = self.width
		self.color.setStroke()
		percentagePath.stroke()
		
		self.image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.text.text = ""
	}
	
	func progressToRadian(progress : CGFloat) -> CGFloat {
		return CGFloat(2 * M_PI) * progress - CGFloat(M_PI / 2)
	}
}
