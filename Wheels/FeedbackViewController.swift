//
//  FeedbackViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 5/3/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackViewController: UIViewController, MFMailComposeViewControllerDelegate {
	
	var parentVC : UIViewController!
	
	var backgroundBlurImageView : UIImageView!
	var dismissButton : UIImageView!
	var yesButton : UIButton!
	var noButton : UIButton!
	var titleLabel : UILabel!
	
	var dialogView : UIView!
	var dialogWidth : CGFloat = 300
	var dialogHeight : CGFloat = 120
	var animationDuration : NSTimeInterval = 0.3
	
	var baseColor : UIColor!
	var secondaryColor : UIColor!
	var dismissButtonColor : UIColor!
	
	var alert : AWAlertView!
	
	init(parentVC : UIViewController, backgroundView : UIView, baseColor : UIColor, secondaryColor : UIColor, dismissButtonColor : UIColor) {
		super.init(nibName: nil, bundle: nil)
		
		self.parentVC = parentVC
		
		self.baseColor = baseColor
		self.secondaryColor = secondaryColor
		self.dismissButtonColor = dismissButtonColor
		
		self.backgroundBlurImageView = UIImageView(frame: backgroundView.bounds)
		self.backgroundBlurImageView.image = UIImage.imageFromUIView(backgroundView).applyKonaDarkEffect()!
		self.backgroundBlurImageView.alpha = 0
		self.view.addSubview(self.backgroundBlurImageView)
		
		self.dialogView = UIView(frame: CGRectMake(0, 0, self.dialogWidth, self.dialogHeight))
		self.dialogView.center = self.view.center
		self.dialogView.backgroundColor = baseColor
		self.dialogView.layer.cornerRadius = 10
		self.dialogView.layer.borderWidth = 1
		self.dialogView.layer.borderColor = secondaryColor.CGColor
		self.view.addSubview(self.dialogView)
		
		self.dismissButton = UIImageView(frame: CGRectMake(20, 40, 25, 25))
		self.dismissButton.image = UIImage(named: "Dismiss")!.coloredImage(dismissButtonColor)
		self.dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
		self.dismissButton.alpha = 0
		self.view.addSubview(self.dismissButton)
		
		self.showFeedbackAlert("Enjoying KonaBot?".localized, badChoiceTitle: "Not really".localized, goodChoiceTitle: "Yes!".localized, badChoiceHandler: {
			self.updateDialogContent("Would you mind giving me some feedback?".localized, goodTitle: "Sure".localized, badTitle: "No, thanks".localized, goodHandler: {
				self.sendEmail()
				self.dismiss()
				}, badHandler: {
					self.dismiss()
			})
			}, goodChoiceHandler: {
				self.updateDialogContent("Then could you help me by rating KonaBot in App Store?".localized, goodTitle: "Sure".localized, badTitle: "No, thanks".localized, goodHandler: {
				UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/konabot/id1055716649")!)
					self.dismiss()
					}, badHandler: {
						self.dismiss()
				})
		})
	}
	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func dismiss(){
		self.rotateDismissBtn(-1)
		UIView.animateWithDuration(self.animationDuration, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
			self.dialogView.center = CGPointMake(UIScreen.mainScreen().bounds.width/2, -self.dialogHeight/2)
			self.backgroundBlurImageView.alpha = 0
			self.dismissButton.alpha = 0
			}, completion: {(finished) in
				self.view.removeFromSuperview()
		})
	}
	
	func showFeedbackAlert(title : String, badChoiceTitle : String, goodChoiceTitle : String, badChoiceHandler : (() -> Void), goodChoiceHandler : (() -> Void)) {
		self.dialogView.center = CGPointMake(UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height + self.dialogHeight/2)
		
		titleLabel = UILabel(frame: CGRectMake(20, 10, self.dialogWidth - 40, 30))
		titleLabel.textAlignment = NSTextAlignment.Center
		titleLabel.lineBreakMode = .ByWordWrapping
		titleLabel.numberOfLines = 0
		titleLabel.textColor = secondaryColor
		titleLabel.text = title
		self.dialogView.addSubview(titleLabel)
		
		yesButton = UIButton(type: .System)
		yesButton.setTitle(goodChoiceTitle, forState: .Normal)
		yesButton.backgroundColor = secondaryColor
		yesButton.setTitleColor(baseColor, forState: .Normal)
		yesButton.layer.cornerRadius = 5
		yesButton.sizeToFit()
		var frame = yesButton.frame
		frame.size.width = self.dialogWidth/3
		yesButton.frame = frame
		yesButton.center = CGPointMake(13/18 * self.dialogWidth, self.dialogHeight - 10 - frame.height/2)
		yesButton.layer.borderWidth = 1
		yesButton.layer.borderColor = secondaryColor.CGColor
		yesButton.block_setAction(goodChoiceHandler)
		self.dialogView.addSubview(yesButton)
		
		noButton = UIButton(type: .System)
		noButton.setTitle(badChoiceTitle, forState: .Normal)
		noButton.setTitleColor(secondaryColor, forState: .Normal)
		noButton.backgroundColor = baseColor
		noButton.layer.cornerRadius = 5
		noButton.sizeToFit()
		var frame_ = noButton.frame
		frame_.size.width = self.dialogWidth/3
		noButton.frame = frame_
		noButton.center = CGPointMake(5/18 * self.dialogWidth, self.dialogHeight - 10 - frame_.height/2)
		noButton.layer.borderWidth = 1
		noButton.layer.borderColor = secondaryColor.CGColor
		noButton.block_setAction(badChoiceHandler)
		self.dialogView.addSubview(noButton)
		
		yesButton.enabled = false
		noButton.enabled = false
		self.dismissButton.userInteractionEnabled = false
		
		self.rotateDismissBtn(1)
		
		UIView.animateWithDuration(self.animationDuration, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
			self.dialogView.center = self.view.center
			self.backgroundBlurImageView.alpha = 1
			self.dismissButton.alpha = 1
			}, completion: {(finished) in
				self.yesButton.enabled = true
				self.noButton.enabled = true
				self.dismissButton.userInteractionEnabled = true
		})
	}
	
	func rotateDismissBtn(numberOfPi : CGFloat) {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.duration = self.animationDuration
		rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		rotateAnimation.toValue = NSNumber(double: Double(numberOfPi) * M_PI)
		self.dismissButton.layer.addAnimation(rotateAnimation, forKey: nil)
	}
	
	func updateDialogContent(title : String, goodTitle : String, badTitle : String, goodHandler : ButtonActionBlock, badHandler : ButtonActionBlock) {
		self.titleLabel.text = title
		let width = self.titleLabel.bounds.width
		self.titleLabel.sizeToFit()
		var frame = self.titleLabel.frame
		frame.size.width = width
		frame.size.height += 8
		self.titleLabel.frame = frame
		self.yesButton.setTitle(goodTitle, forState: .Normal)
		self.noButton.setTitle(badTitle, forState: .Normal)
		self.yesButton.block_setAction(goodHandler)
		self.noButton.block_setAction(badHandler)
	}
	
	func sendEmail() {
		let mailComposeViewController = configuredMailComposeViewController()
		if MFMailComposeViewController.canSendMail() {
			self.presentViewController(mailComposeViewController, animated: true, completion: nil)
		} else {
			self.showSendMailErrorAlert()
		}
	}
	
	func configuredMailComposeViewController() -> MFMailComposeViewController {
		let mailComposerVC = MFMailComposeViewController()
		mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
		
		mailComposerVC.setToRecipients(["email@hkalexling.com"])
		mailComposerVC.setSubject("KonaBot iOS App Feedback")
		
		return mailComposerVC
	}
	
	func showSendMailErrorAlert() {
		self.alert = AWAlertView.redAlertFromTitleAndMessage("Could Not Send Email".localized, message: "Your device could not send email. Please check e-mail configuration and try again.".localized)
		self.parentVC.navigationController?.view.addSubview(self.alert)
		self.alert.showAlert()
	}
	
	// MARK: MFMailComposeViewControllerDelegate
	
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		controller.dismissViewControllerAnimated(true, completion: nil)
		if error != nil {
			self.alert = AWAlertView.redAlertFromTitleAndMessage("Error".localized, message: error!.localizedDescription)
			self.parentVC.navigationController?.view.addSubview(self.alert)
			self.alert.showAlert()
		}
		else if result == MFMailComposeResultSent {
			self.alert = AWAlertView.alertFromTitleAndMessage("Thanks".localized, message: "Thanks for your feedback!".localized)
			self.parentVC.navigationController?.view.addSubview(self.alert)
			self.alert.showAlert()
		}
	}
}
