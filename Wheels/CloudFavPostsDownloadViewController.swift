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
	
	fileprivate var blurImageView : UIImageView!
	fileprivate var dismissButton : UIImageView!
	fileprivate var progressView : AWProgressIndicatorView!
	fileprivate var messageLabel : UILabel!
	fileprivate var delegate : CloudFavPostDownloadVCDelegate?
	
	fileprivate var animationDuration : TimeInterval = 0.3
	
	init(backgroundVC : UIViewController, color : UIColor, delegate : CloudFavPostDownloadVCDelegate?){
		super.init(nibName: nil, bundle: nil)
		
		self.delegate = delegate
		
		self.blurImageView = UIImageView(frame: backgroundVC.view.bounds)
		self.blurImageView.image = UIImage.imageFromUIView(backgroundVC.view).applyKonaDarkEffect()
		self.blurImageView.alpha = 0
		self.view.addSubview(self.blurImageView)
		
		self.dismissButton = UIImageView(frame: CGRect(x: 20, y: 40, width: 25, height: 25))
		self.dismissButton.image = UIImage(named: "Dismiss")!.coloredImage(color)
		self.dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismiss as (Void) -> Void)))
		self.dismissButton.alpha = 0
		self.view.addSubview(self.dismissButton)
		
		self.progressView = AWProgressIndicatorView(color: color, textColor: color, bgColor: UIColor.clear, showText: true, width: 10, radius: 80, font: UIFont.systemFont(ofSize: 40))
		self.progressView.center = self.view.center
		self.blurImageView.addSubview(self.progressView)
		
		self.messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.progressView.frame.size.width, height: 10))
		self.messageLabel.textColor = color
		self.messageLabel.textAlignment = .center
		self.messageLabel.numberOfLines = 0
		self.messageLabel.lineBreakMode = .byWordWrapping
		self.messageLabel.font = UIFont.systemFont(ofSize: 20)
		self.messageLabel.sizeToFitKeepingWidth()
		self.messageLabel.center = CGPoint(x: self.progressView.center.x, y: self.progressView.frame.maxY + 10 + self.messageLabel.frame.size.height/2)
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
		UIView.animate(withDuration: self.animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
			self.blurImageView.alpha = 1
			self.dismissButton.alpha = 1
			}, completion: {(finished) in
				self.dismissButton.isUserInteractionEnabled = true
		})
	}
	
	func dismiss(){
		self.delegate?.CloudFavPostDownloadViewControllerWillDismiss()
		self.rotateDismissBtn(-1)
		UIView.animate(withDuration: self.animationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
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
	
	func setProgress(_ progress : CGFloat) {
		self.progressView.updateProgress(progress)
	}
	
	func setMessage(_ message : String) {
		self.messageLabel.text = message
		self.messageLabel.sizeToFitKeepingWidth()
	}
	
	fileprivate func rotateDismissBtn(_ numberOfPi : CGFloat) {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.duration = self.animationDuration
		rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		rotateAnimation.toValue = NSNumber(value: Double(numberOfPi) * M_PI)
		self.dismissButton.layer.add(rotateAnimation, forKey: nil)
	}
}
