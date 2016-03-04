//
//  AWAlertView.swift
//  AWAlertView
//
//  Created by Alex Ling on 13/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class AWAlertView: UIView {
	
	let width = UIScreen.mainScreen().bounds.width
	let height = UIScreen.mainScreen().bounds.height
	
	let offset : CGFloat = 30
	let labelOffset : CGFloat = 20
	
	var animationDuration : NSTimeInterval = 0.5
	var alertShowTime : NSTimeInterval = 2
	
	var cornerRadius : CGFloat = 15
	
	var alertHidden : Bool = true
	
	var alertHiddenFrame : CGRect!
	var alertShownFrame : CGRect!
	
	var widthPercentage : CGFloat = 0.95
	
	init(title : String, message : String, height : CGFloat, bgColor : UIColor, textColor : UIColor){
		
		self.alertHiddenFrame = CGRectMake((1 - self.widthPercentage)/2 * self.width, -height - self.offset, self.widthPercentage * self.width, height + self.offset)
		self.alertShownFrame = CGRectMake((1 - self.widthPercentage)/2 * self.width, -self.offset, self.widthPercentage * self.width, height + self.offset)
		
		super.init(frame: self.alertHiddenFrame)
		
		self.backgroundColor = bgColor
		self.layer.cornerRadius = self.cornerRadius
		
		let titleLabel = UILabel(frame: CGRectMake(self.labelOffset, self.offset, self.alertHiddenFrame.width - 2 * self.labelOffset, self.frame.height/2))
		titleLabel.text = title
		titleLabel.font = UIFont.boldSystemFontOfSize(18)
		titleLabel.textColor = textColor
		titleLabel.textAlignment = .Center
		self.addSubview(titleLabel)
		
		let messageLabel = UILabel(frame: CGRectMake(self.labelOffset, self.frame.height/2, self.alertHiddenFrame.width - 2 * self.labelOffset, self.frame.height/2))
		messageLabel.text = message
		messageLabel.numberOfLines = 0
		messageLabel.lineBreakMode = .ByWordWrapping
		messageLabel.font = UIFont.systemFontOfSize(15)
		messageLabel.textColor = textColor
		messageLabel.textAlignment = .Center
		self.addSubview(messageLabel)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func showAlert(){
		self.alertHidden = false
		UIView.animateWithDuration(self.animationDuration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options : [], animations: {
			self.frame = self.alertShownFrame
			}, completion: {(finished) in
				UIView.animateWithDuration(self.animationDuration, delay: self.alertShowTime, usingSpringWithDamping: 0.9, initialSpringVelocity: 15, options : [], animations: {
					self.frame = self.alertHiddenFrame
					}, completion: {(finished) in
						self.alertHidden = true
				})
		})
	}
}
