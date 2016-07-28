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
	func awImageViewDidFinishDownloading(_ image : UIImage?, error : NSError?)
}

enum AWImageViewBackgroundStyle {
	case lightBlur
	case extraLightBlur
	case darkBlur
	case none
}

extension UIImage {
	class func imageWithColorAndSize(_ color : UIColor, size : CGSize) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		color.setFill()
		UIRectFill(rect)
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}
	
	class func imageFromUIView(_ view : UIView) -> UIImage{
		UIGraphicsBeginImageContext(view.frame.size)
		view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image!
	}
}

class AWImageViewController: UIViewController, URLSessionDownloadDelegate {
	
	private var delegate : AWImageViewControllerDelegate?
	private var longPressDelegate : AWImageViewControllerLongPressDelegate?
	private var downloadDelegate : AWImageViewControllerDownloadDelegate?
	
	private var animationDuration : TimeInterval?
	
	private var parentView : UIView!
	private var backgroundStyle : AWImageViewBackgroundStyle?
	private var bgImageView : UIImageView!
	
	private var originImageView : UIImageView!
	var image : UIImage!
	private var originFrame : CGRect!
	
	private var scrollView : UIScrollView!
	private var imageView : UIImageView?
	
	private var finishedDisplaying : Bool = false
	
	private var awIndicator : AWProgressIndicatorView!
	
	private var urlString : String?
	private var downloadTask : URLSessionDownloadTask?
	
	private var dismissButton : UIImageView!
	private var dismissButtonColor : UIColor!
	private var dismissButtonWidth : CGFloat!
	
	private var panRecognizer : UIPanGestureRecognizer!
	private var lastTranslation : CGFloat = 0
	private var thresholdVelocity : CGFloat = 2500
	private var maxVelocity : CGFloat = 0
	
	var progressIndicatorColor : UIColor = UIColor.white()
	var progressIndicatorTextColor : UIColor = UIColor.white()
	var progressIndicatorBgColor : UIColor = UIColor.clear()
	var progressIndicatorShowLabel : Bool = true
	var progressIndicatorWidth : CGFloat = 10
	var progressIndicatorLabelFont : UIFont = UIFont.systemFont(ofSize: 40)
	var progressIndicatorRadius : CGFloat = 80
	
	func setup(_ urlString : String?, originImageView : UIImageView, parentView : UIView, backgroundStyle : AWImageViewBackgroundStyle?, animationDuration : TimeInterval?, dismissButtonColor : UIColor, dismissButtonWidth : CGFloat, delegate : AWImageViewControllerDelegate?, longPressDelegate : AWImageViewControllerLongPressDelegate?, downloadDelegate : AWImageViewControllerDownloadDelegate?){
		
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
		self.view.isHidden = false
		if self.backgroundStyle == nil {
			self.backgroundStyle = .none
		}
		
		if self.animationDuration == nil {
			self.animationDuration = 0.3
		}
		
		self.view.frame = self.parentView.bounds
		self.parentView.addSubview(self.view)
		
		self.originFrame = self.originImageView!.convert(self.originImageView!.bounds, to: nil)
		
		if self.urlString != nil {
			self.imageFromUrl(self.urlString!)
		}
		else{
			self.image = originImageView!.image
		}
		
		if self.backgroundStyle != .none {
			var bgImg : UIImage
			if self.backgroundStyle == .lightBlur {
				bgImg = UIImage.imageFromUIView(self.parentView).applyLightEffect()!
			}
			else if self.backgroundStyle == .extraLightBlur {
				bgImg = UIImage.imageFromUIView(self.parentView).applyExtraLightEffect()!
			}
			else{
				bgImg = UIImage.imageFromUIView(self.parentView).applyKonaDarkEffect()!
			}
			self.bgImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main().bounds.width, height: UIScreen.main().bounds.height))
			self.bgImageView.image = bgImg
			self.view.addSubview(self.bgImageView)
		}
		
		self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main().bounds.width, height: UIScreen.main().bounds.height))
		self.scrollView.showsHorizontalScrollIndicator = false
		self.scrollView.showsVerticalScrollIndicator = false
		
		self.view.addSubview(self.scrollView)
		
		self.awIndicator = AWProgressIndicatorView(color: self.progressIndicatorColor, textColor: self.progressIndicatorTextColor, bgColor: self.progressIndicatorBgColor, showText: self.progressIndicatorShowLabel, width: self.progressIndicatorWidth, radius: self.progressIndicatorRadius, font: self.progressIndicatorLabelFont)
		self.awIndicator.isHidden = true
		self.awIndicator.center = self.view.center
		self.view.addSubview(self.awIndicator)
		
		self.view.backgroundColor = UIColor.clear()
		
		self.dismissButton = UIImageView(frame: CGRect(x: 20, y: 40, width: self.dismissButtonWidth, height: self.dismissButtonWidth))
		self.dismissButton.image = UIImage(named: "Dismiss")!.coloredImage(self.dismissButtonColor)
		self.dismissButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismiss as (Void) -> Void)))
		self.dismissButton.isUserInteractionEnabled = true
		self.view.addSubview(self.dismissButton)
		
		self.rotateDismissBtn(1)
		
		let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AWImageViewController.singleTapped))
		let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AWImageViewController.doubleTapped(_:)))
		doubleTapRecognizer.numberOfTapsRequired = 2
		singleTapRecognizer.require(toFail: doubleTapRecognizer)
		
		self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AWImageViewController.panned(_:)))
		
		if self.urlString == nil {
			self.imageView = UIImageView(frame: self.originFrame!)
			imageView!.image = self.image
			self.scrollView.addSubview(self.imageView!)
			self.imageView!.isUserInteractionEnabled = true
			self.imageView!.addGestureRecognizer(singleTapRecognizer)
			self.imageView!.addGestureRecognizer(doubleTapRecognizer)
			self.imageView!.addGestureRecognizer(self.panRecognizer)
		}

		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(AWImageViewController.pinched(_:)))
		self.view.addGestureRecognizer(pinchRecognizer)
		
		let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AWImageViewController.longPressed))
		self.view.addGestureRecognizer(longPressRecognizer)
		
		if self.urlString == nil {
			self.initialAnimation()
		}
		else{
			if self.backgroundStyle == .none {
				UIView.animate(withDuration: self.animationDuration!, animations: {
					self.view.backgroundColor = UIColor.black()
					}, completion: {(finished : Bool) in
						self.awIndicator.isHidden = false
				})
			}
			else{
				self.awIndicator.isHidden = false
			}
		}
	}
	
	func pinched(_ sender: UIPinchGestureRecognizer) {
		if self.finishedDisplaying {
			if sender.state == UIGestureRecognizerState.ended {
				if self.imageView!.frame.width < UIScreen.main().bounds.width {
					let scale : CGFloat = UIScreen.main().bounds.width / self.imageView!.frame.width
					self.imageView!.transform = self.imageView!.transform.scaleBy(x: scale, y: scale)
				}
			}
			else{
				self.imageView!.transform = self.imageView!.transform.scaleBy(x: sender.scale, y: sender.scale)
				sender.scale = 1
			}
			self.updateContentInset()
		}
	}

	func singleTapped(){
		self.dismiss()
	}
	
	func doubleTapped(_ sender : UITapGestureRecognizer){
		if self.finishedDisplaying {
			self.toggleFullSize()
		}
	}
	
	func panned(_ sender : UIPanGestureRecognizer){
		if sender.state == .began {
		}
		if sender.state == .changed {
			var frame = sender.view!.frame
			frame.origin.y += sender.translation(in: self.view).y - self.lastTranslation
			sender.view!.frame = frame
			self.lastTranslation = sender.translation(in: self.view).y
			
			if abs(sender.velocity(in: self.view).y) > self.maxVelocity {
				self.maxVelocity = abs(sender.velocity(in: self.view).y)
			}
		}
		if sender.state == .ended || sender.state == .cancelled {
			if self.maxVelocity > self.thresholdVelocity {
				self.panResetParameters()
				self.panDismiss(sender.velocity(in: self.view).y)
			}
			else{
				UIView.animate(withDuration: self.animationDuration!, animations: {
					sender.view!.center = self.view.center
					}, completion: {(finished) in
						self.panResetParameters()
				})
			}
		}
	}
	
	func panResetParameters() {
		self.lastTranslation = 0
		self.maxVelocity = 0
	}
    
	func initialAnimation(){
		UIView.animate(withDuration: self.animationDuration!, animations: {
			if self.backgroundStyle == .none {
				self.view.backgroundColor = UIColor.black()
			}
			let width : CGFloat = UIScreen.main().bounds.width
			let height : CGFloat = width * self.image.size.height/self.image.size.width
			self.imageView!.frame = CGRect(x: 0, y: UIScreen.main().bounds.height/2 - height/2, width: width, height: height)
			}, completion: {(finished : Bool) in
				self.finishedDisplaying = true
				self.updateContentInset()
		})
	}
	
	func toggleFullSize(){
		if abs(self.imageView!.bounds.width - UIScreen.main().bounds.width) < 1 {
			
			self.panRecognizer.isEnabled = false
			
			let width : CGFloat = self.image.size.width
			let height : CGFloat = self.image.size.height
			UIView.animate(withDuration: self.animationDuration!, animations: {
				self.imageView!.frame = CGRect(x: UIScreen.main().bounds.width/2 - width/2, y: UIScreen.main().bounds.height/2 - height/2, width: width, height: height)
				}, completion: {(finished : Bool) in
					self.updateContentInset()
			})
		}
		else{
			UIView.animate(withDuration: self.animationDuration!, animations: {
				let width : CGFloat = UIScreen.main().bounds.width
				let height : CGFloat = width * self.image.size.height/self.image.size.width
				self.imageView!.frame = CGRect(x: 0, y: UIScreen.main().bounds.height/2 - height/2, width: width, height: height)
				self.updateContentInset()
				}, completion: {(finished) in
					self.panRecognizer.isEnabled = true
			})
		}
	}
	
	func panDismiss(_ velocity : CGFloat) {
		self.downloadTask?.cancel()
		self.awIndicator.isHidden = true
		
		let deltaY = velocity * CGFloat(self.animationDuration!)
		let destination = CGPoint(x: self.imageView!.center.x, y: self.imageView!.center.y + deltaY)
		
		self.rotateDismissBtn(-1)
		
		UIView.animate(withDuration: self.animationDuration!, animations: {
			self.imageView!.center = destination
			self.bgImageView.alpha = 0
			self.dismissButton.alpha = 0
			}, completion: {(finished) in
				self.view.isHidden = true
				for child in self.view.subviews {
					child.removeFromSuperview()
				}
				self.delegate?.awImageViewDidDismiss()
		})
	}
	
	func dismiss(){
		self.downloadTask?.cancel()
		self.awIndicator.isHidden = true

		self.rotateDismissBtn(-1)
		
		UIView.animate(withDuration: self.animationDuration!, animations: {
			self.view.backgroundColor = UIColor.clear()
			if self.imageView == nil {
				//Dismiss during download
				self.view.alpha += 0.1
			}
			else{
				self.imageView!.frame = self.originFrame
				self.updateContentInset()
			}
			}, completion: {(finished : Bool) in
				self.view.isHidden = true
				for child in self.view.subviews {
					child.removeFromSuperview()
				}
				self.delegate?.awImageViewDidDismiss()
		})
	}
	
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
			self.awImageViewDidLongPress()
		}
		else{
			self.longPressDelegate?.awImageViewDidLongPress()
		}
	}
	
	func awImageViewDidLongPress(){
		if self.imageView != nil {
			if self.imageView!.bounds.width == UIScreen.main().bounds.width {
				let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
				
				let saveAction = UIAlertAction(title: "Save Image", style: .default, handler: {(alert : UIAlertAction) -> Void in
					UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
				})
				let copyAction = UIAlertAction(title: "Copy Image", style: .default, handler: {(alert : UIAlertAction) -> Void in
					UIPasteboard.general().image = self.image
				})
				let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
				sheet.addAction(saveAction)
				sheet.addAction(copyAction)
				sheet.addAction(cancelAction)
				
				if let popoverController = sheet.popoverPresentationController {
					popoverController.sourceView = self.imageView
					popoverController.sourceRect = self.imageView!.bounds
				}
				
				self.present(sheet, animated: true, completion: nil)
			}
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		DispatchQueue.main.async{
			self.awIndicator.updateProgress(CGFloat(totalBytesWritten)/(CGFloat)(totalBytesExpectedToWrite))
		}
	}
	
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		let downloadedImage = UIImage(data: try! Data(contentsOf: location))!
		DispatchQueue.main.async{
			
			self.downloadDelegate?.awImageViewDidFinishDownloading(downloadedImage, error: nil)
			
			let imgWidth = downloadedImage.size.width
			let imgHeight = downloadedImage.size.height
			let finalHeight = UIScreen.main().bounds.width * imgHeight/imgWidth
			self.imageView = UIImageView(frame: CGRect(x: 0, y: UIScreen.main().bounds.height/2 - finalHeight/2, width: UIScreen.main().bounds.width, height: finalHeight))
			self.imageView!.image = downloadedImage
			self.image = downloadedImage
			
			let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AWImageViewController.singleTapped))
			let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AWImageViewController.doubleTapped(_:)))
			doubleTapRecognizer.numberOfTapsRequired = 2
			singleTapRecognizer.require(toFail: doubleTapRecognizer)
			
			self.scrollView.addSubview(self.imageView!)
			self.imageView!.isUserInteractionEnabled = true
			self.imageView!.addGestureRecognizer(singleTapRecognizer)
			self.imageView!.addGestureRecognizer(doubleTapRecognizer)
			self.imageView!.addGestureRecognizer(self.panRecognizer)
			
			self.awIndicator.isHidden = true
			self.finishedDisplaying = true
		}
	}
	
	func imageFromUrl(_ url : String) {
		if let nsUrl = URL(string: url){
			let session = Foundation.URLSession(configuration: URLSessionConfiguration.default(), delegate: self, delegateQueue: nil)
			self.downloadTask = session.downloadTask(with: nsUrl)
			self.downloadTask?.resume()
		}
	}
	
	func rotateDismissBtn(_ numberOfPi : CGFloat) {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotateAnimation.duration = self.animationDuration!
		rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		rotateAnimation.toValue = NSNumber(value: Double(numberOfPi) * M_PI)
		self.dismissButton.layer.add(rotateAnimation, forKey: nil)
	}
	
	func frameClose (_ frame0 : CGRect, frame1 : CGRect) -> Bool {
		return abs(frame0.origin.x - frame1.origin.x) < 1 && abs(frame0.origin.y - frame1.origin.y) < 1 && abs(frame0.width - frame1.width) < 1 && abs(frame0.height - frame1.height) < 1
	}
}
