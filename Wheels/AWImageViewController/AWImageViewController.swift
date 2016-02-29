//
//  AWImageViewController.swift
//  AWImageViewController
//
//  Created by Alex Ling on 5/12/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

//Conform to this delegate to get dismiss call back
protocol AWImageViewControllerDelegate {
	func awImageViewDidDismiss()
}

//Conform to this delegate to override what happen when long pressed
protocol AWImageViewControllerLongPressDelegate {
	func awImageViewDidLongPress()
}

protocol AWImageViewControllerDownloadDelegate {
	func awImageViewDidFinishDownloading(image : UIImage)
}

enum AWImageViewBackgroundStyle {
	case LightBlur
	case ExtraLightBlur
	case DarkBlur
	case None
}

extension UIImage {
	class func imageWithColorAndSize(color : UIColor, size : CGSize) -> UIImage {
		let rect = CGRectMake(0, 0, size.width, size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	
	class func imageFromUIView(view : UIView) -> UIImage{
		UIGraphicsBeginImageContext(view.frame.size)
		view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
}

class AWImageViewController: UIViewController, UIScrollViewDelegate, NSURLSessionDownloadDelegate {
	
	private var delegate : AWImageViewControllerDelegate?
	private var longPressDelegate : AWImageViewControllerLongPressDelegate?
	private var downloadDelegate : AWImageViewControllerDownloadDelegate?
	
	private var animationDuration : NSTimeInterval?
	
	private var parentView : UIView!
	private var backgroundStyle : AWImageViewBackgroundStyle?
	private var bgImageView : UIImageView!
	
	private var originImageView : UIImageView!
	var image : UIImage!
	private var originFrame : CGRect?
	
	private var scrollView : UIScrollView!
	private var imageView : UIImageView?
	
	private var finishedDisplaying : Bool = false
	
	private var awIndicator : AWProgressIndicatorView!
	
	private var urlString : String?
	private var downloadTask : NSURLSessionDownloadTask?
	
	private var dismissButton : UIImageView!
	private var dismissButtonColor : UIColor!
	private var dismissButtonWidth : CGFloat!
	
	var progressIndicatorColor : UIColor = UIColor.whiteColor()
	var progressIndicatorTextColor : UIColor = UIColor.whiteColor()
	var progressIndicatorBgColor : UIColor = UIColor.clearColor()
	var progressIndicatorShowLabel : Bool = true
	var progressIndicatorWidth : CGFloat = 10
	var progressIndicatorLabelFont : UIFont = UIFont.systemFontOfSize(40)
	var progressIndicatorRadius : CGFloat = 80
	
	func setup(urlString : String?, originImageView : UIImageView, parentView : UIView, backgroundStyle : AWImageViewBackgroundStyle?, animationDuration : NSTimeInterval?, dismissButtonColor : UIColor, dismissButtonWidth : CGFloat, delegate : AWImageViewControllerDelegate?, longPressDelegate : AWImageViewControllerLongPressDelegate?, downloadDelegate : AWImageViewControllerDownloadDelegate?){
		
		self.urlString = urlString
		self.originImageView = originImageView
		self.parentView = parentView
		self.backgroundStyle = backgroundStyle
		self.animationDuration = animationDuration
		self.dismissButtonColor = dismissButtonColor
		self.dismissButtonWidth = dismissButtonWidth
		self.delegate = delegate
		self.longPressDelegate = longPressDelegate
		self.downloadDelegate = downloadDelegate
		
		self.initialize()
	}
	
	func initialize(){
		self.view.hidden = false
		if self.backgroundStyle == nil {
			self.backgroundStyle = .None
		}
		
		if self.animationDuration == nil {
			self.animationDuration = 0.3
		}
		
		self.view.frame = self.parentView.bounds
		self.parentView.addSubview(self.view)
		
		self.originFrame = self.originImageView!.convertRect(self.originImageView!.bounds, toView: nil)
		
		if self.urlString != nil {
			self.imageFromUrl(self.urlString!)
		}
		else{
			self.image = originImageView!.image
		}
		
		if self.backgroundStyle != .None {
			var bgImg : UIImage
			if self.backgroundStyle == .LightBlur {
				bgImg = UIImage.imageFromUIView(self.parentView).applyLightEffect()!
			}
			else if self.backgroundStyle == .ExtraLightBlur {
				bgImg = UIImage.imageFromUIView(self.parentView).applyExtraLightEffect()!
			}
			else{
				bgImg = UIImage.imageFromUIView(self.parentView).applyKonaDarkEffect()!
			}
			self.bgImageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
			self.bgImageView.image = bgImg
			self.view.addSubview(self.bgImageView)
		}
		
		self.scrollView = UIScrollView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.showsVerticalScrollIndicator = false
		
		self.view.addSubview(self.scrollView)
		
		self.awIndicator = AWProgressIndicatorView(color: self.progressIndicatorColor, textColor: self.progressIndicatorTextColor, bgColor: self.progressIndicatorBgColor, showText: self.progressIndicatorShowLabel, width: self.progressIndicatorWidth, radius: self.progressIndicatorRadius, font: self.progressIndicatorLabelFont)
		self.awIndicator.hidden = true
		self.awIndicator.center = self.view.center
		self.view.addSubview(self.awIndicator)
				
		if self.originImageView != nil {
			self.imageView = UIImageView(frame: self.originFrame!)
			imageView!.image = self.image
			self.scrollView.addSubview(self.imageView!)
		}
		
		self.view.backgroundColor = UIColor.clearColor()
		
		self.dismissButton = UIImageView(frame: CGRectMake(20, 40, self.dismissButtonWidth, self.dismissButtonWidth))
		self.dismissButton.image = UIImage(named: "Dismiss")!.coloredImage(self.dismissButtonColor)
		self.dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismiss"))
		self.view.addSubview(self.dismissButton)
		
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.duration = self.animationDuration!
		rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		rotateAnimation.toValue = NSNumber(double: M_PI)
		self.dismissButton.layer.addAnimation(rotateAnimation, forKey: nil)
		
		let singleTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("singleTapped"))
		let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("doubleTapped"))
		doubleTapRecognizer.numberOfTapsRequired = 2
		singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
		
		self.view.addGestureRecognizer(singleTapRecognizer)
		self.view.addGestureRecognizer(doubleTapRecognizer)
		
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinched:"))
		self.view.addGestureRecognizer(pinchRecognizer)
		
		let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPressed"))
		self.view.addGestureRecognizer(longPressRecognizer)
		
		if self.urlString == nil {
			self.initialAnimation()
		}
		else{
			if self.backgroundStyle == .None {
				UIView.animateWithDuration(self.animationDuration!, animations: {
					self.view.backgroundColor = UIColor.blackColor()
					}, completion: {(finished : Bool) in
						self.awIndicator.hidden = false
				})
			}
			else{
				self.awIndicator.hidden = false
			}
		}
	}
	
	func pinched(sender: UIPinchGestureRecognizer) {
		if self.finishedDisplaying {
			if sender.state == UIGestureRecognizerState.Ended {
				if self.imageView!.frame.width < UIScreen.mainScreen().bounds.width {
					let scale : CGFloat = UIScreen.mainScreen().bounds.width / self.imageView!.frame.width
					self.imageView!.transform = CGAffineTransformScale(self.imageView!.transform, scale, scale)
				}
			}
			else{
				self.imageView!.transform = CGAffineTransformScale(self.imageView!.transform, sender.scale, sender.scale)
				sender.scale = 1
			}
			self.updateContentInset()
		}
	}

	func singleTapped(){
		self.dismiss()
	}
	
	func doubleTapped(){
		if self.finishedDisplaying {
			self.toggleFullSize()
		}
	}
    
	func initialAnimation(){
		UIView.animateWithDuration(self.animationDuration!, animations: {
			if self.backgroundStyle == .None {
				self.view.backgroundColor = UIColor.blackColor()
			}
			let width : CGFloat = UIScreen.mainScreen().bounds.width
			let height : CGFloat = width * self.image.size.height/self.image.size.width
			self.imageView!.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height/2 - height/2, width, height)
			}, completion: {(finished : Bool) in
				self.finishedDisplaying = true
				self.updateContentInset()
		})
	}
	
	func toggleFullSize(){
		if self.imageView!.bounds.width == UIScreen.mainScreen().bounds.width {
			
			let width : CGFloat = self.image.size.width
			let height : CGFloat = self.image.size.height
			UIView.animateWithDuration(self.animationDuration!, animations: {
				self.imageView!.frame = CGRectMake(UIScreen.mainScreen().bounds.width/2 - width/2, UIScreen.mainScreen().bounds.height/2 - height/2, width, height)
				}, completion: {(finished : Bool) in
					self.updateContentInset()
			})
		}
		else{
			UIView.animateWithDuration(self.animationDuration!, animations: {
				let width : CGFloat = UIScreen.mainScreen().bounds.width
				let height : CGFloat = width * self.image.size.height/self.image.size.width
				self.imageView!.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height/2 - height/2, width, height)
				self.updateContentInset()
			})
		}
	}
	
	func dismiss(){
		self.downloadTask?.cancel()
		self.awIndicator.hidden = true
		
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.duration = self.animationDuration!
		rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		rotateAnimation.toValue = NSNumber(double: -M_PI)
		self.dismissButton.layer.addAnimation(rotateAnimation, forKey: nil)
		
		UIView.animateWithDuration(self.animationDuration!, animations: {
			self.view.backgroundColor = UIColor.clearColor()
			if self.originFrame != nil {
				self.imageView!.frame = self.originFrame!
				self.updateContentInset()
			}
			else if self.imageView != nil {
				self.imageView!.hidden = true
			}
			}, completion: {(finished : Bool) in
				self.view.hidden = true
				for child in self.view.subviews {
					child.removeFromSuperview()
				}
				self.delegate?.awImageViewDidDismiss()
		})
	}
	func awImageViewDidDismiss() {}
	
	func updateContentInset(){
		self.scrollView.contentSize = self.imageView!.frame.size

		var top : CGFloat = 0
		var left : CGFloat = 0
		if self.scrollView.contentSize.width > self.scrollView.bounds.size.width {
			left = (self.scrollView.contentSize.width - self.scrollView.bounds.size.width) / 2
		}
		if self.scrollView.contentSize.height > self.scrollView.bounds.size.height {
			top = (self.scrollView.contentSize.height - self.scrollView.bounds.size.height) / 2
		}
		self.scrollView.contentInset = UIEdgeInsetsMake(top, left, -top, -left)
	}
	
	func longPressed(){
		if self.longPressDelegate == nil {
			awImageViewDidLongPress()
		}
		else{
			self.longPressDelegate?.awImageViewDidLongPress()
		}
	}
	
	func awImageViewDidLongPress(){
		if self.imageView != nil {
			if self.imageView!.bounds.width == UIScreen.mainScreen().bounds.width {
				let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
				
				let saveAction = UIAlertAction(title: "Save Image", style: .Default, handler: {(alert : UIAlertAction) -> Void in
					UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
				})
				let copyAction = UIAlertAction(title: "Copy Image", style: .Default, handler: {(alert : UIAlertAction) -> Void in
					UIPasteboard.generalPasteboard().image = self.image
				})
				let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
				sheet.addAction(saveAction)
				sheet.addAction(copyAction)
				sheet.addAction(cancelAction)
				
				if let popoverController = sheet.popoverPresentationController {
					popoverController.sourceView = self.imageView
					popoverController.sourceRect = self.imageView!.bounds
				}
				
				self.presentViewController(sheet, animated: true, completion: nil)
			}
		}
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		dispatch_async(dispatch_get_main_queue()){
			self.awIndicator.updateProgress(CGFloat(totalBytesWritten)/(CGFloat)(totalBytesExpectedToWrite))
		}
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
		let downloadedImage = UIImage(data: NSData(contentsOfURL: location)!)!
		dispatch_async(dispatch_get_main_queue()){
			
			self.downloadDelegate?.awImageViewDidFinishDownloading(downloadedImage)
			
			let imgWidth = downloadedImage.size.width
			let imgHeight = downloadedImage.size.height
			let finalHeight = UIScreen.mainScreen().bounds.width * imgHeight/imgWidth
			self.imageView = UIImageView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height/2 - finalHeight/2, UIScreen.mainScreen().bounds.width, finalHeight))
			self.imageView!.image = downloadedImage
			self.image = downloadedImage
			self.scrollView.addSubview(self.imageView!)
			self.awIndicator.hidden = true
			self.finishedDisplaying = true
		}
	}
	
	func imageFromUrl(url : String) {
		if let nsUrl = NSURL(string: url){
			let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
			self.downloadTask = session.downloadTaskWithURL(nsUrl)
			self.downloadTask?.resume()
		}
	}
}
