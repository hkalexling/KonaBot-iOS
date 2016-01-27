//
//  AWActionSheet.swift
//  ActionSheet
//
//  Created by Alex Ling on 13/1/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

struct AWActionSheetAction {
	let title : String
	let handler : (() -> Void)
}

protocol AWActionSheetDelegate {
	func awActionSheetDidDismiss()
}

extension UIImage {
	class func imageFromUIView(view : UIView) -> UIImage{
		UIGraphicsBeginImageContext(view.frame.size)
		view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}

class AWActionSheet: UIView {
	
	var buttonColor = UIColor.grayColor()
	var cancelButtonColor = UIColor.darkGrayColor()
	var textColor = UIColor.whiteColor()
	
	var buttonWidth : CGFloat = 300
	var buttonHeight : CGFloat = 40
	var buttonCornerRadius : CGFloat = 10
	
	var gapBetweetnCancelButtonAndOtherButtons : CGFloat = 8
	var gapBetweetButtons : CGFloat = 2
	
	var buttonFont : UIFont = UIFont.systemFontOfSize(16)
	var cancelButtonFont : UIFont = UIFont.boldSystemFontOfSize(16)
	
	var animationDuraton : NSTimeInterval = 0.5
	var damping : CGFloat = 0.4
	
	var delegate : AWActionSheetDelegate?
	
	private var parentView : UIView!
	
	private var actions : [AWActionSheetAction] = []
	private var buttons : [UIButton] = []
	
	private let width = UIScreen.mainScreen().bounds.width
	private let height = UIScreen.mainScreen().bounds.height
	
	private var shown : Bool = false
	
	private let imageView = UIImageView()
	
	private var deltaY : CGFloat = 0
	
	init(parentView : UIView){
		super.init(frame: UIScreen.mainScreen().bounds)
		self.parentView = parentView
	}
	
	init(parentView : UIView, actions : [AWActionSheetAction]) {
		super.init(frame: UIScreen.mainScreen().bounds)
		self.parentView = parentView
		self.actions = actions
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
	
	func addAction (action : AWActionSheetAction) {
		self.actions.append(action)
	}
	
	func dismiss() {
		if !self.shown {return}
		UIView.animateWithDuration(self.animationDuraton, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 15, options: [], animations: {
			for button in self.buttons {
				button.center = CGPointMake(button.center.x, button.center.y + self.deltaY)
			}
			self.imageView.alpha = 0
			}, completion: {(finished) in
				self.removeFromSuperview()
				self.delegate?.awActionSheetDidDismiss()
		})
	}
	
	func buttonTapped(sender : UIButton) {
		self.dismiss()
		self.actions[sender.tag].handler()
	}
	
	func showActionSheet() {
				
		self.imageView.frame = self.frame
		self.imageView.image = UIImage.imageFromUIView(self.parentView).applyLightEffect()
		self.imageView.userInteractionEnabled = true
		self.imageView.alpha = 0
		self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
		self.addSubview(self.imageView)
		
		let cancelButton = UIButton(type: .System)
		cancelButton.backgroundColor = self.cancelButtonColor
		cancelButton.setTitleColor(self.textColor, forState: .Normal)
		cancelButton.setTitle("Cancel".localized, forState: .Normal)
		cancelButton.titleLabel?.font = self.cancelButtonFont
		cancelButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
		cancelButton.frame = CGRectMake((self.width - self.buttonWidth)/2, self.height - self.buttonHeight - 20, self.buttonWidth, self.buttonHeight)
		cancelButton.layer.cornerRadius = self.buttonCornerRadius
		self.buttons.append(cancelButton)
		self.addSubview(cancelButton)
		
		var y : CGFloat = cancelButton.frame.minY - self.gapBetweetnCancelButtonAndOtherButtons - self.buttonHeight
		for var i = self.actions.count - 1; i >= 0; i-- {
			let button = UIButton(type: .System)
			button.backgroundColor = self.buttonColor
			
			button.setTitleColor(self.textColor, forState: .Normal)
			button.setTitle(self.actions[i].title, forState: .Normal)
			button.titleLabel?.font = self.buttonFont
			button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
			button.tag = i
			button.frame = CGRectMake((self.width - self.buttonWidth)/2, y, self.buttonWidth, self.buttonHeight)
			y -= self.buttonHeight + self.gapBetweetButtons
			button.layer.cornerRadius = self.buttonCornerRadius
			self.buttons.append(button)
			self.addSubview(button)
		}
		
		self.deltaY = self.height - self.buttons.last!.frame.minY
		for button in self.buttons {
			button.center = CGPointMake(button.center.x, button.center.y + deltaY)
		}
		
		UIView.animateWithDuration(self.animationDuraton, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: 0, options: [], animations: {
			for button in self.buttons {
				button.center = CGPointMake(button.center.x, button.center.y - self.deltaY)
			}
			self.imageView.alpha = 1
			}, completion: {(finished) in
				self.shown = true
		})
	}
}
