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

class DetailViewController: UIViewController, AWImageViewControllerDownloadDelegate, AWImageViewControllerLongPressDelegate, AWActionSheetDelegate, KonaHTMLParserDelegate, KonaAPIErrorDelegate {
	
	let yuno = Yuno()
	var baseUrl : String = "http://konachan.com"
	
	var post : Post?
	var parsedPost : ParsedPost?
	
	var smallImage : UIImage!
	var detailImageView: UIImageView!
	var postUrl : String!
	var heightOverWidth : CGFloat!
	
	var awImageVC = AWImageViewController()
	
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
	let animationDuration : TimeInterval = 0.3
	var bigFrame : CGRect = CGRect.zero
	var smallFrame : CGRect = CGRect.zero
	
	var originalImage = UIImage()
	
	let loadingBackgroundView = UIView()
	var loadingSize : CGFloat = 80
	
	var alert : AWAlertView?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Feedback counting thing
		if !UserDefaults.standard.bool(forKey: "feedbackFinished") {
			var viewCount = UserDefaults.standard.integer(forKey: "viewCount")
			viewCount += 1
			UserDefaults.standard.set(viewCount, forKey: "viewCount")
		}
		
		//iPad
		if UIScreen.main().bounds.width > 415 {
			self.smallerHeight = 200
		}
				
		self.loadingBackgroundView.frame = self.view.frame
		
		let bgView = UIView(frame: self.view.frame)
		bgView.backgroundColor = UIColor.themeColor()
		self.view.addSubview(bgView)
		
		detailImageView = UIImageView()
		let width = UIScreen.main().bounds.width - 40
		let height = width * self.heightOverWidth
		detailImageView.frame = CGRect(x: (CGSize.screenSize().width - width)/2, y: UIScreen.main().bounds.height/2 - height/2, width: width, height: height)
		detailImageView.isUserInteractionEnabled = true
		self.bigFrame = detailImageView.frame
		self.view.addSubview(detailImageView)
		
		self.detailImageView.image = self.smallImage
		
		let tapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
		self.detailImageView.addGestureRecognizer(tapRecognizer)
		
		self.moreImageView.image = UIImage(named: "More")?.coloredImage(UIColor.konaColor())
		let moreImageViewWidth : CGFloat = 50
		let moreImageViewHeight : CGFloat = moreImageViewWidth * self.moreImageView.image!.size.height/self.moreImageView.image!.size.width
		self.moreImageView.frame = CGRect(x: (CGSize.screenSize().width - moreImageViewWidth)/2, y: CGSize.screenSize().height - moreImageViewHeight - CGFloat.tabBarHeight() - 20, width: moreImageViewWidth, height: moreImageViewHeight)
		self.moreImageView.isUserInteractionEnabled = true
		self.moreImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.moreButtonTapped)))
		self.view.addSubview(self.moreImageView)
		
		self.smallFrame = CGRect(x: 20, y: 20 + CGFloat.navitaionBarHeight() + CGFloat.statusBarHeight(), width: self.smallerHeight / self.heightOverWidth,height: self.smallerHeight)
		let transparentViewFrame = CGRect(x: 0, y: 0, width: CGSize.screenSize().width, height: CGFloat.navitaionBarHeight() + CGFloat.statusBarHeight() + self.smallFrame.height + 40)
		self.smallerImageTransparentView.frame = transparentViewFrame
		self.smallerImageTransparentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.smallerViewTapped)))
		
		self.postDetailTableViewContainer.frame = CGRect(x: 0, y: self.smallerImageTransparentView.frame.maxY, width: CGSize.screenSize().width, height: CGSize.screenSize().height - self.smallerImageTransparentView.frame.maxY - CGFloat.tabBarHeight())
		self.postDetailTableViewContainer.clipsToBounds = true
		
		//swipe
		let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.moreButtonTapped))
		swipeRecognizer.direction = .up
		self.view.addGestureRecognizer(swipeRecognizer)
		
		let downSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.smallerViewTapped))
		downSwipeRecognizer.direction = .down
		self.smallerImageTransparentView.addGestureRecognizer(downSwipeRecognizer)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		
		if !self.shouldDownloadWhenViewAppeared {
			return
		}
		
		//From FavoriteVC
		if self.imageUrl == nil {
			
			let screenshotImageView = UIImageView(frame: self.loadingBackgroundView.frame)
			screenshotImageView.image = UIImage.imageFromUIView(self.tabBarController!.view)
			self.loadingBackgroundView.addSubview(screenshotImageView)
			
			self.moreImageView.isUserInteractionEnabled = false
			self.tabBarController?.view.addSubview(self.loadingBackgroundView)
			
			let blurView = UIImageView(frame: self.loadingBackgroundView.frame)
			blurView.image = UIImage.imageFromUIView(self.tabBarController!.view).applyKonaDarkEffect()
			self.loadingBackgroundView.addSubview(blurView)
			
			let indicator = AWProgressIndicatorView(color: UIColor.konaColor(), textColor: UIColor.konaColor(), bgColor: UIColor.clear(), showText: true, width: 10, radius: 80, font: UIFont.systemFont(ofSize: 40))
			indicator.center = self.view.center
			indicator.startSpin(0.3)
			self.loadingBackgroundView.addSubview(indicator)
			
			self.tabBarController!.view.isUserInteractionEnabled = false
			let konaParser = KonaHTMLParser(delegate: self, errorDelegate: self)
			konaParser.getPostInformation(self.postUrl.hasPrefix("http") ? self.postUrl : self.baseUrl + self.postUrl)
		}
		//From CollectionVC
		else if self.shouldDownloadWhenViewAppeared {
			self.downloadImg(self.imageUrl!)
		}
		
		self.shouldDownloadWhenViewAppeared = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		self.favoriteList = self.yuno.favoriteList()

		if (self.favoriteList.contains(self.postUrl)){
			self.stared()
		}
		else{
			self.unstared()
		}
	}
	
	func stared(){
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star"), style: .done, target: self, action: #selector(self.unstared))
		if (!self.favoriteList.contains(self.postUrl)){
			self.favoriteList.append(self.postUrl)
			self.yuno.saveImageWithKey("FavoritedImage", image: self.detailImageView.image!, key: self.postUrl, skipUpload: false)
		}
	}
	
	func unstared(){
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star Outline"), style: .done, target: self, action: #selector(self.stared))
		if (self.favoriteList.contains(self.postUrl)){
			self.favoriteList.remove(at: self.favoriteList.index(of: self.postUrl)!)
			self.yuno.deleteRecordForKey("FavoritedImage", key: self.postUrl, skipUpload: false)
		}
	}

	func tapped(_ sender : UIGestureRecognizer){
		if self.urlStr != nil {
			var sourceImage : UIImage?
			var sourceUrl : String?
			
			if self.finishedDownload {
				sourceImage = self.detailImageView.image
			}
			else{
				if let img = self.yuno.fetchImageWithKey("Cache", key: self.postUrl){
					sourceImage = img
					self.detailImageView.image = img
				}
				else if let img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.postUrl){
					if self.yuno.checkFullsSizeWithKey(self.postUrl){
						sourceImage = img
						self.detailImageView.image = img
					}
					else{
						sourceUrl = self.urlStr!
					}
				}
				else{
					sourceUrl = self.urlStr!
				}
			}
			
			if sourceImage != nil {sourceUrl = nil}
			
			self.awImageVC.progressIndicatorColor = UIColor.konaColor()
			self.awImageVC.progressIndicatorTextColor = UIColor.konaColor()
			
			self.awImageVC.setup(sourceUrl, originImageView: self.detailImageView, parentView: self.tabBarController!.view, backgroundStyle: .darkBlur, animationDuration: nil, dismissButtonColor: UIColor.konaColor(), dismissButtonWidth: 25, delegate: nil, longPressDelegate: self, downloadDelegate: self)
			
			self.tabBarController!.view.addSubview(self.awImageVC.view)
		}
	}
	
	func downloadImg(_ url : String){
		self.urlStr = url
		var sourceImage : UIImage?
		var sourceUrl : String?
		
		if let img = self.yuno.fetchImageWithKey("Cache", key: self.postUrl){
			sourceImage = img
			self.detailImageView.image = img
		}
		else if let img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.postUrl){
			if self.yuno.checkFullsSizeWithKey(self.postUrl){
				sourceImage = img
				self.detailImageView.image = img
			}
			else{
				sourceUrl = self.urlStr!
			}
		}
		else{
			sourceUrl = url
		}
		
		if sourceImage != nil {sourceUrl = nil}
		
		self.awImageVC.progressIndicatorColor = UIColor.konaColor()
		self.awImageVC.progressIndicatorTextColor = UIColor.konaColor()
		
		self.awImageVC.setup(sourceUrl, originImageView: self.detailImageView, parentView: self.tabBarController!.view, backgroundStyle: .darkBlur, animationDuration: nil, dismissButtonColor: UIColor.konaColor(), dismissButtonWidth: 25, delegate: nil, longPressDelegate: self, downloadDelegate: self)
		
		self.tabBarController!.view.addSubview(self.awImageVC.view)
	}
	
	@objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafePointer<()>) {
		DispatchQueue.main.async(execute: {
			if error == nil {
				self.awAlert("Image Saved".localized, message: "This image has been saved to your camera roll".localized)
			}
			else{
				let alert = AWAlertView.redAlertFromTitleAndMessage("Failed to Save Image".localized, message: "Please detele some unwanted files and try again".localized)
				self.awImageVC.view.addSubview(alert)
				alert.showAlert()
			}
		})
	}
	
	func awAlert(_ title : String, message : String) {
		DispatchQueue.main.async(execute: {
			let alert = AWAlertView.alertFromTitleAndMessage(title, message: message)
			self.awImageVC.view.addSubview(alert)
			alert.showAlert()
		})
	}
	
	func moreButtonTapped(){
		self.moreImageView.isUserInteractionEnabled = false
		UIView.animate(withDuration: self.animationDuration, animations: {
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
		UIView.animate(withDuration: self.animationDuration, animations: {
			self.detailImageView.frame = self.bigFrame
			self.moreImageView.alpha = 1
			self.detailImageView.image = self.originalImage
			}, completion: {(finished) in
				self.smallerImageTransparentView.removeFromSuperview()
				self.moreImageView.isUserInteractionEnabled = true
		})
	}
	
	func awActionSheetDidDismiss() {
		self.allowLongPress = true
	}
	
	func initializePostDetailTableVC (){
		let postDetailTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postDetailTableVC") as! PostDetailTableViewController
		postDetailTableVC.post = self.post
		postDetailTableVC.parsedPost = self.parsedPost
		postDetailTableVC.parentVC = self
		self.addChildViewController(postDetailTableVC)
		postDetailTableVC.view.frame = self.postDetailTableViewContainer.bounds
		self.postDetailTableViewContainer.addSubview(postDetailTableVC.tableView)
	}
	
	func unlock() {
		self.loadingBackgroundView.removeFromSuperview()
		self.tabBarController!.view.isUserInteractionEnabled = true
	}
	
	func konaHTMLParserFinishedParsing(_ parsedPost: ParsedPost) {
		self.unlock()
		self.parsedPost = parsedPost
		self.downloadImg(self.parsedPost!.url)
		self.moreImageView.isUserInteractionEnabled = true
	}
	
	func konaAPIGotError(_ error: NSError) {
		self.unlock()
		let alert = AWAlertView.networkAlertFromError(error)
		self.navigationController?.view.addSubview(alert)
		alert.showAlert()
	}
	
	func shareToSocial (_ serviceType : String) {
		if SLComposeViewController.isAvailable(forServiceType: serviceType) {
			let controller = SLComposeViewController(forServiceType: serviceType)
			controller?.setInitialText("Shared via #KonaBot_iOS".localized)
			controller?.add(self.awImageVC.image)
			controller?.add(URL(string: self.postUrl.hasPrefix("http") ? self.postUrl : self.baseUrl + self.postUrl))
			self.awImageVC.present(controller!, animated: true, completion: nil)
		}
		else{
			let alert = AWAlertView.redAlertFromTitleAndMessage("Service Not Avaiable".localized, message: "Please set up the social account in Settings or use another service".localized)
			alert.alertShowTime = 4
			self.awImageVC.view.addSubview(alert)
			alert.showAlert()
		}
	}
	
	func awImageViewDidLongPress() {
		if !self.allowLongPress {return}
		
		let image = self.awImageVC.image
		
		let awActionSheet = AWActionSheet(parentView: self.awImageVC.view)
		awActionSheet.delegate = self
		
		let saveAction = AWActionSheetAction(title: "Save Image".localized, handler: {
			UIImageWriteToSavedPhotosAlbum(image!, self, #selector(DetailViewController.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
		})
		
		let favoriteAction = AWActionSheetAction(title: "Favorite".localized, handler: {
			self.stared()
		})
		
		let unfavoriteAction = AWActionSheetAction(title: "Unfavorite".localized, handler: {
			self.unstared()
		})
		
		let copyAction = AWActionSheetAction(title: "Copy Image".localized, handler: {
			UIPasteboard.general().image = image
			self.awAlert("Image Copied".localized, message: "This image has been copied to your clipboard".localized)
		})
		
		let copyLinkAction = AWActionSheetAction(title: "Copy Image URL".localized, handler: {
			UIPasteboard.general().string = self.urlStr!
			self.awAlert("URL Copied".localized, message: "The image URL has been copied to your clipboard".localized)
		})
		
		let openAction = AWActionSheetAction(title: "Open Post in Safari".localized, handler: {
			UIApplication.shared().openURL(URL(string: self.postUrl.hasPrefix("http") ? self.postUrl : self.baseUrl + self.postUrl)!)
		})
		
		let shareAction = AWActionSheetAction(title: "Share to...".localized, handler: {
			let twitterAction = AWActionSheetAction(title: "Twitter", handler: {self.shareToSocial(SLServiceTypeTwitter)})
			let facebookAction = AWActionSheetAction(title: "Facebook", handler: {self.shareToSocial(SLServiceTypeFacebook)})
			let weiboAction = AWActionSheetAction(title: "Weibo".localized, handler: {self.shareToSocial(SLServiceTypeSinaWeibo)})
			let shareActionSheet = AWActionSheet(parentView: self.awImageVC.view, actions: [twitterAction, facebookAction, weiboAction])
			Yuno().actionSheetSetStyle(shareActionSheet)
			self.awImageVC.view.addSubview(shareActionSheet)
			shareActionSheet.showActionSheet()
		})
		
		awActionSheet.addAction(saveAction)
		awActionSheet.addAction(self.favoriteList.contains(self.postUrl) ?  unfavoriteAction : favoriteAction)
		awActionSheet.addAction(copyAction)
		awActionSheet.addAction(copyLinkAction)
		awActionSheet.addAction(openAction)
		awActionSheet.addAction(shareAction)
		
		Yuno().actionSheetSetStyle(awActionSheet)
		
		self.awImageVC.view.addSubview(awActionSheet)
		self.allowLongPress = false
		awActionSheet.showActionSheet()
	}
	
	func awImageViewDidFinishDownloading(_ image: UIImage?, error: NSError?) {
		if image != nil {
			self.detailImageView.image = image!
			self.finishedDownload = true
			self.yuno.saveImageWithKey("Cache", image: image!, key: self.postUrl, skipUpload: false)
			self.yuno.saveFavoriteImageIfNecessary(self.postUrl, image: image!)
		}
		if error != nil {
			if let _alert = self.alert {
				if !_alert.alertHidden {
					return
				}
			}
			self.alert = AWAlertView.networkAlertFromError(error!)
			self.navigationController?.view.addSubview(self.alert!)
			self.alert!.showAlert()
		}
	}
}
