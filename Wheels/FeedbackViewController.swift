//
//  FeedbackViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 5/3/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit
import MessageUI

class FeedbackManager: NSObject, MFMailComposeViewControllerDelegate {
	
	var parentVC : UIViewController!
	
	var alert : AWAlertView!
	
	var konaAlertVC : KonaAlertViewController!
	
	init(parentVC : UIViewController, backgroundVC : UIViewController, baseColor : UIColor, secondaryColor : UIColor, dismissButtonColor : UIColor) {
		super.init()
		
		self.konaAlertVC = KonaAlertViewController(backgroundView: backgroundVC.view, baseColor: baseColor, secondaryColor: secondaryColor, dismissButtonColor: dismissButtonColor)
		self.parentVC = parentVC
		backgroundVC.addChildViewController(konaAlertVC)
		backgroundVC.view.addSubview(konaAlertVC.view)
		self.konaAlertVC.showAlert("Enjoying KonaBot?".localized, message: "", badChoiceTitle: "Not really".localized, goodChoiceTitle: "Yes!".localized, badChoiceHandler: {
			self.konaAlertVC.updateDialogContent("Would you mind giving me some feedback?".localized, message: "", goodTitle: "Sure".localized, badTitle: "No, thanks".localized, goodHandler: {
				self.sendEmail()
				self.konaAlertVC.dismiss()
				}, badHandler: {
					self.konaAlertVC.dismiss()
			})
			}, goodChoiceHandler: {
				self.konaAlertVC.updateDialogContent("Then could you help me by rating KonaBot in App Store?".localized, message: "", goodTitle: "Sure".localized, badTitle: "No, thanks".localized, goodHandler: {
					UIApplication.shared().openURL(URL(string: "https://itunes.apple.com/us/app/konabot/id1055716649")!)
					self.konaAlertVC.dismiss()
					}, badHandler: {
						self.konaAlertVC.dismiss()
				})
		})
	}
	
	func sendEmail() {
		let mailComposeViewController = configuredMailComposeViewController()
		if MFMailComposeViewController.canSendMail() {
			self.konaAlertVC.present(mailComposeViewController, animated: true, completion: nil)
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
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: NSError?) {
		controller.dismiss(animated: true, completion: nil)
		if error != nil {
			self.alert = AWAlertView.redAlertFromTitleAndMessage("Error".localized, message: error!.localizedDescription)
			self.parentVC.navigationController?.view.addSubview(self.alert)
			self.alert.showAlert()
		}
		else if result == MFMailComposeResult.sent {
			self.alert = AWAlertView.alertFromTitleAndMessage("Thanks".localized, message: "Thanks for your feedback!".localized)
			self.parentVC.navigationController?.view.addSubview(self.alert)
			self.alert.showAlert()
		}
	}
}
