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
import Social

class DetailViewController: UIViewController, JTSImageViewControllerInteractionsDelegate, AWActionSheetDelegate, KonaHTMLParserDelegate, KonaAPIErrorDelegate {
	
	let yuno = Yuno()
	var baseUrl : String = "http://konachan.com"
	
	var post : Post?
	var parsedPost : ParsedPost?
	
	var smallImage : UIImage!
	var detailImageView: UIImageView!
	var postUrl : String!
	var heightOverWidth : CGFloat!
	
	var imageViewer = JTSImageViewController()
	
	var finishedDownload : Bool = false
	var urlStr : String?
	
	var imageUrl : String?
	
	var favoriteList : [String]!
	
	var shouldDownloadWhenViewAppeared : Bool = true
	var allowLongPress : Bool = true
	
	let moreImageView = UIImageView()
	let postDetailTableViewContainer = UIView()
	var smallerHeight : CGFloat = 100
	let smallerImageTransparentView = UIView()
	let animationDuration : NSTimeInterval = 0.3
	var bigFrame : CGRect = CGRectZero
	var smallFrame : CGRect = CGRectZero
	
	var originalImage = UIImage()
	
	let loadingBackgroundView = UIImageView()
	var loadingSize : CGFloat = 80
	var loadingView : RZSquaresLoading!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//iPad
		if UIScreen.mainScreen().bounds.width > 415 {
			self.smallerHeight = 200
		}
				
		self.loadingBackgroundView.frame = self.view.frame
		
		self.loadingView = RZSquaresLoading(frame: CGRectMake(CGSize.screenSize().width/2 - loadingSize/2, CGSize.screenSize().height/2 - loadingSize/2, loadingSize, loadingSize))
		self.loadingView.color = UIColor.konaColor()
		
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
		
		self.postDetailTableViewContainer.frame = CGRectMake(0, self.smallerImageTransparentView.frame.maxY, CGSize.screenSize().width, CGSize.screenSize().height - self.smallerImageTransparentView.frame.maxY - CGFloat.tabBarHeight())
		self.postDetailTableViewContainer.clipsToBounds = true
    }
	
	override func viewDidAppear(animated: Bool) {
		
		if !self.shouldDownloadWhenViewAppeared {
			return
		}
		
		//From FavoriteVC
		if self.imageUrl == nil {
			self.loadingBackgroundView.image = UIImage.imageFromUIView(self.tabBarController!.view).applyDarkEffect()
			self.moreImageView.userInteractionEnabled = false
			self.tabBarController?.view.addSubview(self.loadingBackgroundView)
			self.loadingBackgroundView.addSubview(self.loadingView)
			self.tabBarController!.view.userInteractionEnabled = false
			let konaParser = KonaHTMLParser(delegate: self, errorDelegate: self)
			konaParser.getPostInformation(self.postUrl.hasPrefix("http") ? self.postUrl : self.baseUrl + self.postUrl)
		}
		//From CollectionVC
		else if self.shouldDownloadWhenViewAppeared {
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
		
		if !self.allowLongPress {return}
		
		let image = self.detailImageView.image!
		
		let awActionSheet = AWActionSheet(parentView: self.imageViewer.view)
		awActionSheet.delegate = self
		
		let saveAction = AWActionSheetAction(title: "Save Image".localized, handler: {
			UIImageWriteToSavedPhotosAlbum(image, self, Selector("imageSaved:didFinishSavingWithError:contextInfo:"), nil)
		})
		
		let favoriteAction = AWActionSheetAction(title: "Favorite".localized, handler: {
			self.stared()
		})
		
		let unfavoriteAction = AWActionSheetAction(title: "Unfavorite".localized, handler: {
			self.unstared()
		})
		
		let copyAction = AWActionSheetAction(title: "Copy Image".localized, handler: {
			UIPasteboard.generalPasteboard().image = image
			self.awAlert("Image Copied".localized, message: "This image has been copied to your clipboard".localized)
		})
		
		let copyLinkAction = AWActionSheetAction(title: "Copy Image URL".localized, handler: {
			UIPasteboard.generalPasteboard().string = self.urlStr!
			self.awAlert("URL Copied".localized, message: "The image URL has been copied to your clipboard".localized)
		})
		
		let openAction = AWActionSheetAction(title: "Open Post in Safari".localized, handler: {
			UIApplication.sharedApplication().openURL(NSURL(string: "\(self.baseUrl)\(self.postUrl)")!)
		})
		
		let shareAction = AWActionSheetAction(title: "Share to...".localized, handler: {
			let twitterAction = AWActionSheetAction(title: "Twitter", handler: {self.shareToSocial(SLServiceTypeTwitter)})
			let facebookAction = AWActionSheetAction(title: "Facebook", handler: {self.shareToSocial(SLServiceTypeFacebook)})
			let weiboAction = AWActionSheetAction(title: "Weibo".localized, handler: {self.shareToSocial(SLServiceTypeSinaWeibo)})
			let shareActionSheet = AWActionSheet(parentView: self.imageViewer.view, actions: [twitterAction, facebookAction, weiboAction])
			self.actionSheetSetStyle(shareActionSheet)
			self.imageViewer.view.addSubview(shareActionSheet)
			shareActionSheet.showActionSheet()
		})
		
		awActionSheet.addAction(saveAction)
		awActionSheet.addAction(self.favoriteList.contains(self.postUrl) ?  unfavoriteAction : favoriteAction)
		awActionSheet.addAction(copyAction)
		awActionSheet.addAction(copyLinkAction)
		awActionSheet.addAction(openAction)
		awActionSheet.addAction(shareAction)
		
		self.actionSheetSetStyle(awActionSheet)
		
		self.imageViewer.view.addSubview(awActionSheet)
		self.allowLongPress = false
		awActionSheet.showActionSheet()
	}
	
	func actionSheetSetStyle (awActionSheet : AWActionSheet ){
		awActionSheet.animationDuraton = 0.8
		awActionSheet.cancelButtonColor = UIColor.themeColor()
		let componets = UIColor.themeColor().components
		awActionSheet.buttonColor = UIColor(red: componets.red, green: componets.green, blue: componets.blue, alpha: 0.8)
		awActionSheet.textColor = UIColor.konaColor()
		
		//iPad
		if UIScreen.mainScreen().bounds.width > 415 {
			awActionSheet.buttonWidth = 400
			awActionSheet.buttonHeight = 60
			awActionSheet.gapBetweetnCancelButtonAndOtherButtons = 15
			awActionSheet.buttonFont = UIFont.systemFontOfSize(20)
			awActionSheet.cancelButtonFont = UIFont.boldSystemFontOfSize(20)
		}
	}
	
	func imageSaved(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafePointer<()>) {
		dispatch_async(dispatch_get_main_queue(), {
			if error == nil {
				self.awAlert("Image Saved".localized, message: "This image has been saved to your camera roll".localized)
			}
			else{
				let alert = AWAlertView.redAlertFromTitleAndMessage("Failed to Save Image".localized, message: "Please detele some unwanted files and try again".localized)
				self.imageViewer.view.addSubview(alert)
				alert.showAlert()
			}
		})
	}
	
	func awAlert(title : String, message : String) {
		dispatch_async(dispatch_get_main_queue(), {
			let alert = AWAlertView.alertFromTitleAndMessage(title, message: message)
			self.imageViewer.view.addSubview(alert)
			alert.showAlert()
		})
	}
	
	func moreButtonTapped(){
		self.moreImageView.userInteractionEnabled = false
		UIView.animateWithDuration(self.animationDuration, animations: {
			self.detailImageView.frame = self.smallFrame
			self.moreImageView.alpha = 0
			}, completion: {(finished) in
				self.view.addSubview(self.smallerImageTransparentView)
				self.view.addSubview(self.postDetailTableViewContainer)
				self.originalImage = self.detailImageView.image!
				self.detailImageView.image = self.detailImageView.image!.resize(2 * self.detailImageView.bounds.width)
				self.initializePostDetailTableVC()
		})
	}
	
	func smallerViewTapped(){
		self.postDetailTableViewContainer.removeFromSuperview()
		UIView.animateWithDuration(self.animationDuration, animations: {
			self.detailImageView.frame = self.bigFrame
			self.moreImageView.alpha = 1
			self.detailImageView.image = self.originalImage
			}, completion: {(finished) in
				self.smallerImageTransparentView.removeFromSuperview()
				self.moreImageView.userInteractionEnabled = true
		})
	}
	
	func awActionSheetDidDismiss() {
		self.allowLongPress = true
	}
	
	func initializePostDetailTableVC (){
		let postDetailTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("postDetailTableVC") as! PostDetailTableViewController
		postDetailTableVC.post = self.post
		postDetailTableVC.parsedPost = self.parsedPost
		postDetailTableVC.parentVC = self
		self.addChildViewController(postDetailTableVC)
		postDetailTableVC.view.frame = self.postDetailTableViewContainer.bounds
		self.postDetailTableViewContainer.addSubview(postDetailTableVC.tableView)
	}
	
	func unlock() {
		self.loadingBackgroundView.removeFromSuperview()
		self.tabBarController!.view.userInteractionEnabled = true
	}
	
	func konaHTMLParserFinishedParsing(parsedPost: ParsedPost) {
		self.unlock()
		self.parsedPost = parsedPost
		self.downloadImg(self.parsedPost!.url)
		self.moreImageView.userInteractionEnabled = true
	}
	
	func konaAPIGotError(error: NSError) {
		self.unlock()
		let alert = AWAlertView.networkAlertFromError(error)
		self.navigationController?.view.addSubview(alert)
		alert.showAlert()
	}
	
	func shareToSocial (serviceType : String) {
		if SLComposeViewController.isAvailableForServiceType(serviceType) {
			let controller = SLComposeViewController(forServiceType: serviceType)
			controller.setInitialText("Shared via #KonaBot_iOS".localized)
			controller.addImage(self.imageViewer.image)
			controller.addURL(NSURL(string: self.postUrl.hasPrefix("http") ? self.postUrl : self.baseUrl + self.postUrl))
			self.imageViewer.presentViewController(controller, animated: true, completion: nil)
		}
		else{
			let alert = AWAlertView.redAlertFromTitleAndMessage("Service Not Avaiable".localized, message: "Please set up the social account in Settings or use another service".localized)
			alert.alertShowTime = 4
			self.imageViewer.view.addSubview(alert)
			alert.showAlert()
		}
	}
}
