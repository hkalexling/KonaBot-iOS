//
//  AWAlertView.swift
//  AWAlertView
//
//  Created by Alex Ling on 13/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class AWAlertView: UIView {
	
	let width = UIScreen.main.bounds.width
	let height = UIScreen.main.bounds.height
	
	let offset : CGFloat = 30
	let labelOffset : CGFloat = 20
	
	var animationDuration : TimeInterval = 0.5
	var alertShowTime : TimeInterval = 2
	
	var cornerRadius : CGFloat = 15
	
	var alertHidden : Bool = true
	
	var alertHiddenFrame : CGRect!
	var alertShownFrame : CGRect!
	
	var widthPercentage : CGFloat = 0.95
	
	init(title : String, message : String, height : CGFloat, bgColor : UIColor, textColor : UIColor){
		
		self.alertHiddenFrame = CGRect(x: (1 - self.widthPercentage)/2 * self.width, y: -height - self.offset, width: self.widthPercentage * self.width, height: height + self.offset)
		self.alertShownFrame = CGRect(x: (1 - self.widthPercentage)/2 * self.width, y: -self.offset, width: self.widthPercentage * self.width, height: height + self.offset)
		
		super.init(frame: self.alertHiddenFrame)
		
		self.backgroundColor = bgColor
		self.layer.cornerRadius = self.cornerRadius
		
		let titleLabel = UILabel(frame: CGRect(x: self.labelOffset, y: self.offset, width: self.alertHiddenFrame.width - 2 * self.labelOffset, height: self.frame.height/2))
		titleLabel.text = title
		titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
		titleLabel.textColor = textColor
		titleLabel.textAlignment = .center
		self.addSubview(titleLabel)
		
		let messageLabel = UILabel(frame: CGRect(x: self.labelOffset, y: self.frame.height/2, width: self.alertHiddenFrame.width - 2 * self.labelOffset, height: self.frame.height/2))
		messageLabel.text = message
		messageLabel.numberOfLines = 0
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.font = UIFont.systemFont(ofSize: 15)
		messageLabel.textColor = textColor
		messageLabel.textAlignment = .center
		self.addSubview(messageLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func showAlert(){
		self.alertHidden = false
		UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options : [], animations: {
			self.frame = self.alertShownFrame
			}, completion: {(finished) in
				UIView.animate(withDuration: self.animationDuration, delay: self.alertShowTime, usingSpringWithDamping: 0.9, initialSpringVelocity: 15, options : [], animations: {
					self.frame = self.alertHiddenFrame
					}, completion: {(finished) in
						self.alertHidden = true
				})
		})
	}
}
