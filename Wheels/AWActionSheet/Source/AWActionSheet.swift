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

class AWActionSheet: UIView {
	
	var buttonColor = UIColor.gray
	var cancelButtonColor = UIColor.darkGray
	var textColor = UIColor.white
	
	var buttonWidth : CGFloat = 300
	var buttonHeight : CGFloat = 40
	var buttonCornerRadius : CGFloat = 10
	
	var gapBetweetnCancelButtonAndOtherButtons : CGFloat = 8
	var gapBetweetButtons : CGFloat = 2
	
	var buttonFont : UIFont = UIFont.systemFont(ofSize: 16)
	var cancelButtonFont : UIFont = UIFont.boldSystemFont(ofSize: 16)
	
	var animationDuraton : TimeInterval = 0.5
	var damping : CGFloat = 0.4
	
	var delegate : AWActionSheetDelegate?
	
	fileprivate var parentView : UIView!
	
	fileprivate var actions : [AWActionSheetAction] = []
	fileprivate var buttons : [UIButton] = []
	
	fileprivate let width = UIScreen.main.bounds.width
	fileprivate let height = UIScreen.main.bounds.height
	
	fileprivate var shown : Bool = false
	
	fileprivate let imageView = UIImageView()
	
	fileprivate var deltaY : CGFloat = 0
	
	init(parentView : UIView){
		super.init(frame: UIScreen.main.bounds)
		self.parentView = parentView
	}
	
	init(parentView : UIView, actions : [AWActionSheetAction]) {
		super.init(frame: UIScreen.main.bounds)
		self.parentView = parentView
		self.actions = actions
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func addAction (_ action : AWActionSheetAction) {
		self.actions.append(action)
	}
	
	func dismiss() {
		if !self.shown {return}
		UIView.animate(withDuration: self.animationDuraton, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 15, options: [], animations: {
			for button in self.buttons {
				button.center = CGPoint(x: button.center.x, y: button.center.y + self.deltaY)
			}
			self.imageView.alpha = 0
			}, completion: {(finished) in
				self.removeFromSuperview()
				self.delegate?.awActionSheetDidDismiss()
		})
	}
	
	func buttonTapped(_ sender : UIButton) {
		self.dismiss()
		self.actions[sender.tag].handler()
	}
	
	func showActionSheet() {
				
		self.imageView.frame = self.frame
		self.imageView.image = UIImage.imageFromUIView(self.parentView).applyLightEffect()
		self.imageView.isUserInteractionEnabled = true
		self.imageView.alpha = 0
		self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AWActionSheet.dismiss)))
		self.addSubview(self.imageView)
		
		let cancelButton = UIButton(type: .system)
		cancelButton.backgroundColor = self.cancelButtonColor
		cancelButton.setTitleColor(self.textColor, for: UIControlState())
		cancelButton.setTitle("Cancel".localized, for: UIControlState())
		cancelButton.titleLabel?.font = self.cancelButtonFont
		cancelButton.addTarget(self, action: #selector(AWActionSheet.dismiss), for: .touchUpInside)
		cancelButton.frame = CGRect(x: (self.width - self.buttonWidth)/2, y: self.height - self.buttonHeight - 20, width: self.buttonWidth, height: self.buttonHeight)
		cancelButton.layer.cornerRadius = self.buttonCornerRadius
		self.buttons.append(cancelButton)
		self.addSubview(cancelButton)
		
		var y : CGFloat = cancelButton.frame.minY - self.gapBetweetnCancelButtonAndOtherButtons - self.buttonHeight
		for var i in 1 ... self.actions.count {
			i = self.actions.count - i
			let button = UIButton(type: .system)
			button.backgroundColor = self.buttonColor
			
			button.setTitleColor(self.textColor, for: UIControlState())
			button.setTitle(self.actions[i].title, for: UIControlState())
			button.titleLabel?.font = self.buttonFont
			button.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
			button.tag = i
			button.frame = CGRect(x: (self.width - self.buttonWidth)/2, y: y, width: self.buttonWidth, height: self.buttonHeight)
			y -= self.buttonHeight + self.gapBetweetButtons
			button.layer.cornerRadius = self.buttonCornerRadius
			self.buttons.append(button)
			self.addSubview(button)
		}
		
		self.deltaY = self.height - self.buttons.last!.frame.minY
		for button in self.buttons {
			button.center = CGPoint(x: button.center.x, y: button.center.y + deltaY)
		}
		
		UIView.animate(withDuration: self.animationDuraton, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: 0, options: [], animations: {
			for button in self.buttons {
				button.center = CGPoint(x: button.center.x, y: button.center.y - self.deltaY)
			}
			self.imageView.alpha = 1
			}, completion: {(finished) in
				self.shown = true
		})
	}
}
