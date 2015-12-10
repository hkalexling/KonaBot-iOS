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
	
	private var animationDuration : NSTimeInterval?
	
	private var parentView : UIView!
	private var backgroundStyle : AWImageViewBackgroundStyle?
	private var bgImageView : UIImageView!
	
	private var originImageView : UIImageView?
	private var image : UIImage!
	private var originFrame : CGRect?
	
	private var scrollView : UIScrollView!
	private var imageView : UIImageView?
	
	private var finishedDisplaying : Bool = false
	
	private let indicator = UIImageView()
	private let indicatorText = UILabel()
	
	private var urlString : String?
	
	var progressIndicatorColor : UIColor = UIColor.whiteColor()
	var progressIndicatorTextColor : UIColor = UIColor.whiteColor()
	var progressIndicatorBgColor : UIColor = UIColor.clearColor()
	var progressIndicatorShowLabel : Bool = true
	var progressIndicatorWidth : CGFloat = 10
	var progressIndicatorLabelFont : UIFont = UIFont.systemFontOfSize(40)
	var progressIndicatorRadius : CGFloat = 80
	
	func setup(originImageView : UIImageView, parentView : UIView, backgroundStyle : AWImageViewBackgroundStyle?, animationDuration : NSTimeInterval?, delegate : AWImageViewControllerDelegate?, longPressDelegate : AWImageViewControllerLongPressDelegate?){
		
		self.originImageView = originImageView
		self.parentView = parentView
		self.backgroundStyle = backgroundStyle
		self.animationDuration = animationDuration
		self.delegate = delegate
		self.longPressDelegate = longPressDelegate
		
		self.initialize()
	}
	
	func setupWithUrl(urlString : String, parentView : UIView, backgroundStyle : AWImageViewBackgroundStyle?, animationDuration : NSTimeInterval?, delegate : AWImageViewControllerDelegate?, longPressDelegate : AWImageViewControllerLongPressDelegate?){
		
		self.urlString = urlString
		self.parentView = parentView
		self.backgroundStyle = backgroundStyle
		self.animationDuration = animationDuration
		self.delegate = delegate
		self.longPressDelegate = longPressDelegate
		
		self.initialize()
	}
	
	func initialize(){
		if self.backgroundStyle == nil {
			self.backgroundStyle = .None
		}
		
		if self.animationDuration == nil {
			self.animationDuration = 0.3
		}
		
		self.view.frame = self.parentView.bounds
		self.parentView.addSubview(self.view)
		
		if self.originImageView != nil {
			self.originFrame = self.originImageView!.convertRect(self.originImageView!.bounds, toView: nil)
			self.image = originImageView!.image
			self.originImageView!.image = UIImage.imageWithColorAndSize(UIColor.clearColor(), size: CGSizeMake(10, 10))
		}
		else{
			self.imageFromUrl(self.urlString!)
		}
		
		if self.backgroundStyle != .None {
			var bgImg : UIImage
			if self.backgroundStyle == .LightBlur {
				bgImg = UIImage.imageFromUIView(self.parentView).applyLightEffect()
			}
			else if self.backgroundStyle == .ExtraLightBlur {
				bgImg = UIImage.imageFromUIView(self.parentView).applyExtraLightEffect()
			}
			else{
				bgImg = UIImage.imageFromUIView(self.parentView).applyDarkEffect()
			}
			self.bgImageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
			self.bgImageView.image = bgImg
			self.view.addSubview(self.bgImageView)
		}
		
		self.scrollView = UIScrollView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.showsVerticalScrollIndicator = false
		
		self.view.addSubview(self.scrollView)
		
		self.indicator.frame = CGRectMake(UIScreen.mainScreen().bounds.width/2 - self.progressIndicatorRadius, UIScreen.mainScreen().bounds.height/2 - self.progressIndicatorRadius, self.progressIndicatorRadius * 2, self.progressIndicatorRadius * 2)
		self.indicator.hidden = true
		self.view.addSubview(self.indicator)
		
		self.indicatorText.frame = CGRectMake(0, 0, self.progressIndicatorRadius * 2, self.progressIndicatorRadius * 2)
		self.indicatorText.textAlignment = NSTextAlignment.Center
		self.indicatorText.backgroundColor = UIColor.clearColor()
		self.indicatorText.textColor = self.progressIndicatorTextColor
		self.indicatorText.font = self.progressIndicatorLabelFont
		self.indicator.addSubview(self.indicatorText)
		
		if self.originImageView != nil {
			self.imageView = UIImageView(frame: self.originFrame!)
			imageView!.image = self.image
			self.scrollView.addSubview(self.imageView!)
		}
		
		self.view.backgroundColor = UIColor.clearColor()
		
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
		
		if self.originImageView != nil {
			self.initialAnimation()
		}
		else{
			if self.backgroundStyle == .None {
				UIView.animateWithDuration(self.animationDuration!, animations: {
					self.view.backgroundColor = UIColor.blackColor()
					}, completion: {(finished : Bool) in
						self.indicator.hidden = false
				})
			}
			else{
				self.indicator.hidden = false
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
		self.indicator.hidden = true
		UIView.animateWithDuration(self.animationDuration!, animations: {
			self.view.backgroundColor = UIColor.clearColor()
			if self.originFrame != nil {
				self.imageView!.frame = self.originFrame!
			}
			else if self.imageView != nil {
				self.imageView!.hidden = true
			}
			}, completion: {(finished : Bool) in
				self.view.hidden = true //I know I shouldn't simply hide it, but if I use `self.view.removeFromSuperview()`, the `didSelectItemAtIndexPath` method in collection view controller won't get called again. I might come back and fix this later
				self.originImageView?.image = self.image
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
			longPressDelegate?.awImageViewDidLongPress()
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
			self.setProgress(CGFloat(totalBytesWritten)/(CGFloat)(totalBytesExpectedToWrite))
		}
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
		let downloadedImage = UIImage(data: NSData(contentsOfURL: location)!)!
		dispatch_async(dispatch_get_main_queue()){
			let imgWidth = downloadedImage.size.width
			let imgHeight = downloadedImage.size.height
			let finalHeight = UIScreen.mainScreen().bounds.width * imgHeight/imgWidth
			self.imageView = UIImageView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height/2 - finalHeight/2, UIScreen.mainScreen().bounds.width, finalHeight))
			self.imageView!.image = downloadedImage
			self.image = downloadedImage
			self.scrollView.addSubview(self.imageView!)
			self.indicator.hidden = true
			self.finishedDisplaying = true
		}
	}
	
	func imageFromUrl(url : String) {
		if let nsUrl = NSURL(string: url){
			let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
			let downloadTask = session.downloadTaskWithURL(nsUrl)
			downloadTask.resume()
		}
	}
	
	func setProgress(progress : CGFloat){
		UIGraphicsBeginImageContextWithOptions(CGSize(width: 2 * self.progressIndicatorRadius + self.progressIndicatorWidth, height: 2 * self.progressIndicatorRadius + self.progressIndicatorWidth), false, 0)
		
		let bgPath = UIBezierPath(arcCenter: CGPointMake(self.progressIndicatorRadius + self.progressIndicatorWidth/2, self.progressIndicatorRadius + self.progressIndicatorWidth/2), radius: self.progressIndicatorRadius, startAngle: 0, endAngle: CGFloat(2.0 * M_PI), clockwise: true)
		bgPath.lineWidth = self.progressIndicatorWidth
		self.progressIndicatorBgColor.setStroke()
		bgPath.stroke()
		
		let percentagePath = UIBezierPath(arcCenter: CGPointMake(self.progressIndicatorRadius + self.progressIndicatorWidth/2, self.progressIndicatorRadius + self.progressIndicatorWidth/2), radius: self.progressIndicatorRadius, startAngle: CGFloat(-0.5 * M_PI), endAngle: self.progressToRadian(progress), clockwise: true)
		percentagePath.lineWidth = self.progressIndicatorWidth
		self.progressIndicatorColor.setStroke()
		percentagePath.stroke()
		
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		self.indicator.image = img
		self.indicatorText.text = "\(Int(progress * 100))%"
	}
	
	func progressToRadian(progress : CGFloat) -> CGFloat {
		return CGFloat(2.0 * M_PI) * progress - CGFloat(0.5 * M_PI)
	}
}
