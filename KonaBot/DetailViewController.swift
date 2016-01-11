//
//  DetailViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 1/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit
import Kanna
import CoreData
import AFNetworking

class DetailViewController: UIViewController, JTSImageViewControllerInteractionsDelegate{
	
	let yuno = Yuno()
	var baseUrl : String = "http://konachan.com"
	
	var smallImage : UIImage!
	var detailImageView: UIImageView!
	var postUrl : String!
	var heightOverWidth : CGFloat!
	
	var imageViewer = JTSImageViewController()
	
	var finishedDownload : Bool = false
	var urlStr : String?
	
	var imageUrl : String?
	
	var favoriteList : [String]!
	
	let blockView = UIView()
	
	var shouldDownloadWhenViewAppeared : Bool = true
	
	let moreImageView = UIImageView()
	let smallerHeight : CGFloat = 100
	let smallerImageTransparentView = UIView()
	let animationDuration : NSTimeInterval = 0.3
	var bigFrame : CGRect = CGRectZero
	var smallFrame : CGRect = CGRectZero
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.hidesBackButton = true
		
		//I don't know why but simply setting `tabBar.userInteractionEnabled = false` does not work. So I am using this dirty approach.
		self.blockView.frame = CGRectMake(0, 0, CGSize.screenSize().width, 100)
		self.tabBarController?.tabBar.addSubview(self.blockView)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "unlock:", name: "unlock", object: nil)
		
		let bgView = UIView(frame: self.view.frame)
		bgView.backgroundColor = UIColor.themeColor()
		self.view.addSubview(bgView)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloaded:"), name: "finishedDownloading", object: nil)
		
		detailImageView = UIImageView()
		let width = UIScreen.mainScreen().bounds.width - 40
		let height = width * self.heightOverWidth
		detailImageView.frame = CGRectMake((CGSize.screenSize().width - width)/2, UIScreen.mainScreen().bounds.height/2 - height/2, width, height)
		detailImageView.userInteractionEnabled = true
		self.bigFrame = detailImageView.frame
		self.view.addSubview(detailImageView)
		
		self.detailImageView.image = self.smallImage
		
		let tapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
		self.detailImageView.addGestureRecognizer(tapRecognizer)
		
		self.moreImageView.image = UIImage(named: "More")?.coloredImage(UIColor.konaColor())
		let moreImageViewWidth : CGFloat = 50
		let moreImageViewHeight : CGFloat = moreImageViewWidth * self.moreImageView.image!.size.height/self.moreImageView.image!.size.width
		self.moreImageView.frame = CGRectMake((CGSize.screenSize().width - moreImageViewWidth)/2, CGSize.screenSize().height - moreImageViewHeight - CGFloat.tabBarHeight() - 20, moreImageViewWidth, moreImageViewHeight)
		self.moreImageView.userInteractionEnabled = true
		self.moreImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "moreButtonTapped"))
		self.view.addSubview(self.moreImageView)
		
		self.smallFrame = CGRectMake(20, 20 + CGFloat.navitaionBarHeight() + CGFloat.statusBarHeight(), self.smallerHeight / self.heightOverWidth,self.smallerHeight)
		let transparentViewFrame = CGRectMake(0, 0, CGSize.screenSize().width, CGFloat.navitaionBarHeight() + CGFloat.statusBarHeight() + self.smallFrame.height + 40)
		self.smallerImageTransparentView.frame = transparentViewFrame
		self.smallerImageTransparentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "smallerViewTapped"))
		
		if self.imageUrl == nil {
			self.moreImageView.userInteractionEnabled = false
			self.getHtml(self.postUrl.hasPrefix("http") ? self.postUrl : self.baseUrl + self.postUrl)
		}
    }
	
	override func viewDidAppear(animated: Bool) {
		
		if self.imageUrl == nil {
			return
		}
		
		if self.shouldDownloadWhenViewAppeared {
			self.downloadImg(self.imageUrl!)
		}
		self.shouldDownloadWhenViewAppeared = false
	}
	
	override func viewWillAppear(animated: Bool) {
		
		self.favoriteList = self.yuno.favoriteList()

		if (self.favoriteList.contains(self.postUrl)){
			self.stared()
		}
		else{
			self.unstared()
		}
	}
	
	func stared(){
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star"), style: .Done, target: self, action: Selector("unstared"))
		if (!self.favoriteList.contains(self.postUrl)){
			self.favoriteList.append(self.postUrl)
			self.yuno.saveImageWithKey("FavoritedImage", image: self.detailImageView.image!, key: self.postUrl)
		}
	}
	
	func unstared(){
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star Outline"), style: .Done, target: self, action: Selector("stared"))
		if (self.favoriteList.contains(self.postUrl)){
			self.favoriteList.removeAtIndex(self.favoriteList.indexOf(self.postUrl)!)
			self.yuno.deleteRecordForKey("FavoritedImage", key: self.postUrl)
		}
	}
	
	func downloaded(sender : NSNotification){
		if (self.imageViewer.image != nil){
			self.detailImageView.image = self.imageViewer.image
			self.finishedDownload = true
			self.yuno.saveImageWithKey("Cache", image: self.detailImageView.image!, key: self.postUrl)
			self.yuno.saveFavoriteImageIfNecessary(self.postUrl, image: self.detailImageView.image!)
		}
	}
	
	func tapped(sender : UIGestureRecognizer){
		if (self.urlStr != nil){
			let imageInfo = JTSImageInfo()
			if self.finishedDownload{
				imageInfo.image = self.detailImageView.image
			}
			else{
				if let img = self.yuno.fetchImageWithKey("Cache", key: self.postUrl){
					imageInfo.image = img
					self.detailImageView.image = img
				}
				else if let img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.postUrl){
					if self.yuno.checkFullsSizeWithKey(self.postUrl){
						imageInfo.image = img
						self.detailImageView.image = img
					}
					else{
						imageInfo.imageURL = NSURL(string: self.urlStr!)
					}
				}
				else{
					imageInfo.imageURL = NSURL(string: self.urlStr!)
				}
			}
			imageInfo.referenceRect = self.detailImageView.frame
			imageInfo.referenceView = self.view
			
			self.imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: [.Blurred, .Scaled])
			self.imageViewer.interactionsDelegate = self
			
			imageViewer.showFromViewController(self, transition: .FromOriginalPosition)
		}
	}
	
	func getHtml(url : String){
		let manager = AFHTTPSessionManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		
		manager.GET(url, parameters: nil, progress: nil,
			success: {(operation, responseObject) -> Void in
				
				let html : NSString = NSString(data: responseObject as! NSData, encoding: NSASCIIStringEncoding)!
				self.parse(html as String)
				
			}, failure: {(operation, error) -> Void in
				print ("Error : \(error)")
				let alert = UIAlertController.alertWithOKButton("Network Error".localized, message: error.localizedDescription)
				self.presentViewController(alert, animated: true, completion: nil)
		})
	}
	
	func parse(htmlString : String){
		if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
			for div in doc.css("div#right-col"){
				let img = div.at_css("div")?.at_css("img")
				downloadImg(img!["src"]!)
				return
			}
		}
	}
	
	func downloadImg(url : String){
		self.urlStr = url
		let imageInfo = JTSImageInfo()
		imageInfo.referenceRect = self.detailImageView.frame
		imageInfo.referenceView = self.view
		
		if let img = self.yuno.fetchImageWithKey("Cache", key: self.postUrl){
			imageInfo.image = img
			self.detailImageView.image = img
		}
		else if let img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.postUrl){
			if self.yuno.checkFullsSizeWithKey(self.postUrl){
				imageInfo.image = img
				self.detailImageView.image = img
			}
			else{
				imageInfo.imageURL = NSURL(string: self.urlStr!)
			}
		}
		else{
			imageInfo.imageURL = NSURL(string: url)
		}
		
		self.imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: [.Blurred, .Scaled])
		self.imageViewer.interactionsDelegate = self
		
		imageViewer.showFromViewController(self, transition: .FromOriginalPosition)
	}
	
	func imageViewerDidLongPress(imageViewer: JTSImageViewController!, atRect rect: CGRect) {
		
		let image = self.detailImageView.image!
		
		let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
		
		let saveAction = UIAlertAction(title: "Save Image".localized, style: .Default, handler: {(alert : UIAlertAction) -> Void in
			UIImageWriteToSavedPhotosAlbum(image, self, Selector("imageSaved:didFinishSavingWithError:contextInfo:"), nil)
		})
		
		let favoriteAction = UIAlertAction(title: "Favorite".localized, style: .Default, handler: {(alert : UIAlertAction) -> Void in
			self.stared()
		})
		
		let unfavoriteAction = UIAlertAction(title: "Unfavorite".localized, style: .Default, handler: {(alert : UIAlertAction) -> Void in
			self.unstared()
		})
		
		let copyAction = UIAlertAction(title: "Copy Image".localized, style: .Default, handler: {(alert : UIAlertAction) -> Void in
			UIPasteboard.generalPasteboard().image = image
			self.alertWithOkButton("Image Copied".localized, message: "This image has been copied to your clipboard".localized)
		})
		
		let copyLinkAction = UIAlertAction(title: "Copy Image URL".localized, style: .Default, handler: {(alert : UIAlertAction) -> Void in
			UIPasteboard.generalPasteboard().string = self.urlStr!
			self.alertWithOkButton("URL Copied".localized, message: "The image URL has been copied to your clipboard".localized)
		})
		
		let openAction = UIAlertAction(title: "Open Post in Safari".localized, style: UIAlertActionStyle.Default, handler: {(alert : UIAlertAction) -> Void in
			UIApplication.sharedApplication().openURL(NSURL(string: "\(self.baseUrl)\(self.postUrl)")!)
		})
		
		let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil)
		
		sheet.addAction(saveAction)
		if (self.favoriteList.contains(self.postUrl)){
			sheet.addAction(unfavoriteAction)
		}
		else{
			sheet.addAction(favoriteAction)
		}
		sheet.addAction(copyAction)
		sheet.addAction(copyLinkAction)
		sheet.addAction(openAction)
		sheet.addAction(cancelAction)
		
		if let popoverController = sheet.popoverPresentationController {
			popoverController.sourceView = self.detailImageView
			popoverController.sourceRect = self.detailImageView.bounds
		}
		
		self.imageViewer.presentViewController(sheet, animated: true, completion: nil)
	}
	
	func imageSaved(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
		dispatch_async(dispatch_get_main_queue(), {
			self.alertWithOkButton("Image Saved".localized, message: "This image has been saved to your camera roll".localized)
		})
	}
	
	func alertWithOkButton(title : String?, message : String?){
		dispatch_async(dispatch_get_main_queue(), {
			UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK".localized).show()
		})
	}
	
	func unlock (sender : NSNotification) {
		let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			self.navigationItem.hidesBackButton = false
			self.moreImageView.userInteractionEnabled = true
			self.blockView.removeFromSuperview()
		})
	}
	
	func moreButtonTapped(){
		self.moreImageView.userInteractionEnabled = false
		UIView.animateWithDuration(self.animationDuration, animations: {
			self.detailImageView.frame = self.smallFrame
			self.moreImageView.alpha = 0
			}, completion: {(finished) in
				self.view.addSubview(self.smallerImageTransparentView)
		})
	}
	
	func smallerViewTapped(){
		UIView.animateWithDuration(self.animationDuration, animations: {
			self.detailImageView.frame = self.bigFrame
			self.moreImageView.alpha = 1
			}, completion: {(finished) in
				self.smallerImageTransparentView.removeFromSuperview()
				self.moreImageView.userInteractionEnabled = true
		})
	}
}
