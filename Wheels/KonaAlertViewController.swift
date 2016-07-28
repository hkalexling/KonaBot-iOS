//
//  KonaAlertViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 19/3/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

class KonaAlertViewController: UIViewController {
	
	private var backgroundBlurImageView : UIImageView!
	private var dismissButton : UIImageView!
	private var yesButton : UIButton!
	private var noButton : UIButton!
	private var titleLabel : UILabel!
	private var messageLabel : UILabel?
	
	private var dialogView : UIView!
	private var dialogWidth : CGFloat = 300
	private var dialogHeight : CGFloat?
	private var animationDuration : TimeInterval = 0.3
	
	private var baseColor : UIColor!
	private var secondaryColor : UIColor!
	private var dismissButtonColor : UIColor!
	
	init(backgroundView : UIView, baseColor : UIColor, secondaryColor : UIColor, dismissButtonColor : UIColor) {
		super.init(nibName: nil, bundle: nil)
		
		self.baseColor = baseColor
		self.secondaryColor = secondaryColor
		self.dismissButtonColor = dismissButtonColor
		
		self.backgroundBlurImageView = UIImageView(frame: backgroundView.bounds)
		self.backgroundBlurImageView.image = UIImage.imageFromUIView(backgroundView).applyKonaDarkEffect()!
		self.backgroundBlurImageView.alpha = 0
		self.view.addSubview(self.backgroundBlurImageView)
		
		self.dialogView = UIView(frame: CGRect(x: 0, y: 0, width: self.dialogWidth, height: 10))
		self.dialogView.center = self.view.center
		self.dialogView.backgroundColor = baseColor
		self.dialogView.layer.cornerRadius = 10
		self.dialogView.layer.borderWidth = 1
		self.dialogView.layer.borderColor = secondaryColor.cgColor
		self.view.addSubview(self.dialogView)
		
		self.dismissButton = UIImageView(frame: CGRect(x: 20, y: 40, width: 25, height: 25))
		self.dismissButton.image = UIImage(named: "Dismiss")!.coloredImage(dismissButtonColor)
		self.dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismiss as (Void) -> Void)))
		self.dismissButton.alpha = 0
		self.view.addSubview(self.dismissButton)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func dismiss(){
		self.rotateDismissBtn(-1)
		UIView.animate(withDuration: self.animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
			self.dialogView.center = CGPoint(x: UIScreen.main().bounds.width/2, y: -self.dialogHeight!/2)
			self.backgroundBlurImageView.alpha = 0
			self.dismissButton.alpha = 0
			}, completion: {(finished) in
				self.view.removeFromSuperview()
		})
	}
	
	func showAlert(_ title : String, message : String?, badChoiceTitle : String, goodChoiceTitle : String, badChoiceHandler : (() -> Void), goodChoiceHandler : (() -> Void)) {
		
		self.titleLabel = UILabel(frame: CGRect(x: 20, y: 10, width: self.dialogWidth - 40, height: 30))
		self.titleLabel.textAlignment = NSTextAlignment.center
		self.titleLabel.lineBreakMode = .byWordWrapping
		self.titleLabel.numberOfLines = 0
		self.titleLabel.textColor = self.secondaryColor
		self.titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
		self.dialogView.addSubview(self.titleLabel)
		
		if let _ = message {
			self.messageLabel = UILabel(frame: CGRect(x: 20, y: self.titleLabel.frame.maxY + 10, width: self.dialogWidth - 40, height: 30))
			self.messageLabel!.textAlignment = .center
			self.messageLabel!.lineBreakMode = .byWordWrapping
			self.messageLabel!.numberOfLines = 0
			self.messageLabel!.textColor = self.secondaryColor
			self.messageLabel!.font = UIFont.systemFont(ofSize: 14)
			self.dialogView.addSubview(self.messageLabel!)
		}
		
		self.yesButton = UIButton(type: .system)
		self.yesButton.backgroundColor = self.secondaryColor
		self.yesButton.setTitleColor(self.baseColor, for: UIControlState())
		self.yesButton.layer.cornerRadius = 5
		var frame = self.yesButton.frame
		frame.size.width = self.dialogWidth/3
		self.yesButton.frame = frame
		self.yesButton.center = CGPoint(x: 13/18 * self.dialogWidth, y: 10)
		self.yesButton.layer.borderWidth = 1
		self.yesButton.layer.borderColor = self.secondaryColor.cgColor
		self.dialogView.addSubview(self.yesButton)
		
		self.noButton = UIButton(type: .system)
		self.noButton.setTitleColor(self.secondaryColor, for: UIControlState())
		self.noButton.backgroundColor = self.baseColor
		self.noButton.layer.cornerRadius = 5
		var frame_ = self.noButton.frame
		frame_.size.width = self.dialogWidth/3
		self.noButton.frame = frame_
		self.noButton.center = CGPoint(x: 5/18 * self.dialogWidth, y: 10)
		self.noButton.layer.borderWidth = 1
		self.noButton.layer.borderColor = self.secondaryColor.cgColor
		self.dialogView.addSubview(self.noButton)
		
		self.updateDialogContent(title, message: message, goodTitle: goodChoiceTitle, badTitle: badChoiceTitle, goodHandler: goodChoiceHandler, badHandler: badChoiceHandler)
		let maxY = self.yesButton.frame.maxY
		self.dialogView.center = CGPoint(x: UIScreen.main().bounds.width/2, y: UIScreen.main().bounds.height + (maxY + 20)/2)
		
		self.yesButton.isEnabled = false
		self.noButton.isEnabled = false
		self.dismissButton.isUserInteractionEnabled = false
		
		self.rotateDismissBtn(1)
		
		UIView.animate(withDuration: self.animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
			self.dialogView.center = self.view.center
			self.backgroundBlurImageView.alpha = 1
			self.dismissButton.alpha = 1
			}, completion: {(finished) in
				self.yesButton.isEnabled = true
				self.noButton.isEnabled = true
				self.dismissButton.isUserInteractionEnabled = true
		})
	}
	
	func rotateDismissBtn(_ numberOfPi : CGFloat) {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.duration = self.animationDuration
		rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		rotateAnimation.toValue = NSNumber(value: Double(numberOfPi) * M_PI)
		self.dismissButton.layer.add(rotateAnimation, forKey: nil)
	}
	
	func updateDialogContent(_ title : String, message : String?, goodTitle : String, badTitle : String, goodHandler : ButtonActionBlock, badHandler : ButtonActionBlock) {
		
		var dialogViewFrameTemp = self.dialogView.frame
		let tempOrignY = dialogViewFrameTemp.origin.y
		dialogViewFrameTemp.origin.y = 0
		self.dialogView.frame = dialogViewFrameTemp
		
		self.titleLabel.text = title
		self.titleLabel.sizeToFitKeepingWidth()
		
		if let message_ = message {
			self.messageLabel!.frame = CGRect(x: 20, y: self.titleLabel.frame.maxY + 10, width: self.dialogWidth - 40, height: 30)
			self.messageLabel!.text = message_
			self.messageLabel!.sizeToFitKeepingWidth()
		}
		
		var maxY = self.messageLabel == nil ? self.titleLabel.frame.maxY : self.messageLabel!.frame.maxY
		
		self.yesButton.setTitle(goodTitle, for: UIControlState())
		self.yesButton.sizeToFit()
		var frame = self.yesButton.frame
		frame.size.width = self.dialogWidth/3
		self.yesButton.frame = frame
		self.yesButton.center = CGPoint(x: 13/18 * self.dialogWidth, y: maxY + 10 + frame.height/2)
		self.yesButton.block_setAction(goodHandler)

		self.noButton.setTitle(badTitle, for: UIControlState())
		self.noButton.sizeToFit()
		var frame_ = self.noButton.frame
		frame_.size.width = self.dialogWidth/3
		self.noButton.frame = frame_
		self.noButton.center = CGPoint(x: 5/18 * self.dialogWidth, y: maxY + 10 + frame.height/2)
		self.noButton.block_setAction(badHandler)
		
		maxY = self.yesButton.frame.maxY
		self.dialogHeight = maxY + 10
		var frameTemp = self.dialogView.frame
		frameTemp.size.height = self.dialogHeight!
		frameTemp.origin.y = tempOrignY
		self.dialogView.frame = frameTemp
		
		self.dialogView.center = self.view.center
	}
}

extension UILabel {
	func sizeToFitKeepingWidth() {
		let originalWidth = self.frame.size.width
		self.sizeToFit()
		self.frame.size.width = originalWidth
	}
}

