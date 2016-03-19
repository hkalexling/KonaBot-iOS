//
//  CloudFavPostsDownloadViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 20/3/2016.
//  Copyright © 2016 Alex Ling. All rights reserved.
//

import UIKit

protocol CloudFavPostDownloadVCDelegate {
	func CloudFavPostDownloadViewControllerWillDismiss()
}

class CloudFavPostsDownloadViewController: UIViewController {
	
	private var blurImageView : UIImageView!
	private var dismissButton : UIImageView!
	private var progressView : AWProgressIndicatorView!
	private var messageLabel : UILabel!
	private var delegate : CloudFavPostDownloadVCDelegate?
	
	private var animationDuration : NSTimeInterval = 0.3
	
	init(backgroundVC : UIViewController, color : UIColor, delegate : CloudFavPostDownloadVCDelegate?){
		super.init(nibName: nil, bundle: nil)
		
		self.delegate = delegate
		
		self.blurImageView = UIImageView(frame: backgroundVC.view.bounds)
		self.blurImageView.image = UIImage.imageFromUIView(backgroundVC.view).applyKonaDarkEffect()
		self.blurImageView.alpha = 0
		self.view.addSubview(self.blurImageView)
		
		self.dismissButton = UIImageView(frame: CGRectMake(20, 40, 25, 25))
		self.dismissButton.image = UIImage(named: "Dismiss")!.coloredImage(color)
		self.dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
		self.dismissButton.alpha = 0
		self.view.addSubview(self.dismissButton)
		
		self.progressView = AWProgressIndicatorView(color: color, textColor: color, bgColor: UIColor.clearColor(), showText: true, width: 10, radius: 80, font: UIFont.systemFontOfSize(40))
		self.progressView.center = self.view.center
		self.blurImageView.addSubview(self.progressView)
		
		self.messageLabel = UILabel(frame: CGRectMake(0, 0, self.progressView.frame.size.width, 10))
		self.messageLabel.textColor = color
		self.messageLabel.textAlignment = .Center
		self.messageLabel.numberOfLines = 0
		self.messageLabel.lineBreakMode = .ByWordWrapping
		self.messageLabel.font = UIFont.systemFontOfSize(20)
		self.messageLabel.sizeToFitKeepingWidth()
		self.messageLabel.center = CGPointMake(self.progressView.center.x, self.progressView.frame.maxY + 10 + self.messageLabel.frame.size.height/2)
		self.blurImageView.addSubview(self.messageLabel)
		
		backgroundVC.addChildViewController(self)
		backgroundVC.view.addSubview(self.view)
	}
	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func show() {
		UIView.animateWithDuration(self.animationDuration, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
			self.blurImageView.alpha = 1
			self.dismissButton.alpha = 1
			}, completion: {(finished) in
				self.dismissButton.userInteractionEnabled = true
		})
	}
	
	func dismiss(){
		self.delegate?.CloudFavPostDownloadViewControllerWillDismiss()
		self.rotateDismissBtn(-1)
		UIView.animateWithDuration(self.animationDuration, delay: 0, options: [UIViewAnimationOptions.CurveEaseInOut], animations: {
			self.blurImageView.alpha = 0
			self.dismissButton.alpha = 0
			}, completion: {(finished) in
				self.view.removeFromSuperview()
		})
	}
	
	func startSpin() {
		self.progressView.startSpin(0.3)
	}
	
	func stopSpin() {
		self.progressView.stopSpin()
	}
	
	func setProgress(progress : CGFloat) {
		self.progressView.updateProgress(progress)
	}
	
	func setMessage(message : String) {
		self.messageLabel.text = message
		self.messageLabel.sizeToFitKeepingWidth()
	}
	
	private func rotateDismissBtn(numberOfPi : CGFloat) {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.duration = self.animationDuration
		rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		rotateAnimation.toValue = NSNumber(double: Double(numberOfPi) * M_PI)
		self.dismissButton.layer.addAnimation(rotateAnimation, forKey: nil)
	}
}
