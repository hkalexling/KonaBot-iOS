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

class DetailViewController: UIViewController, JTSImageViewControllerInteractionsDelegate{
	
	let yuno = Yuno()
	
	var smallImage : UIImage!
	var detailImageView: UIImageView!
	var postUrl : String!
	var heightOverWidth : CGFloat!
	
	var imageViewer = JTSImageViewController()
	
	var finishedDownload : Bool = false
	var urlStr : String?
	
	var favoriteList : [String]!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("downloaded:"), name: "finishedDownloading", object: nil)
		
		detailImageView = UIImageView()
		let width = UIScreen.mainScreen().bounds.width - 40
		let height = width * self.heightOverWidth
		detailImageView.frame = CGRectMake((CGSize.screenSize().width - width)/2, UIScreen.mainScreen().bounds.height/2 - height/2, width, height)
		detailImageView.userInteractionEnabled = true
		self.view.addSubview(detailImageView)
		
		self.detailImageView.image = self.smallImage
        self.getHtml("http://konachan.net\(postUrl)")
		
		let tapRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
		self.detailImageView.addGestureRecognizer(tapRecognizer)
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
			//self.yuno.saveFavorite(self.postUrl)
			self.yuno.saveImageWithKey("FavoritedImage", image: self.detailImageView.image!, key: self.postUrl)
		}
	}
	
	func unstared(){
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star Outline"), style: .Done, target: self, action: Selector("stared"))
		if (self.favoriteList.contains(self.postUrl)){
			self.favoriteList.removeAtIndex(self.favoriteList.indexOf(self.postUrl)!)
			//self.yuno.removeFromFavorite(self.postUrl)
			self.yuno.deleteRecordForKey("FavoritedImage", key: self.postUrl)
		}
	}
	
	func downloaded(sender : NSNotification){
		if (self.imageViewer.image != nil){
			self.detailImageView.image = self.imageViewer.image
			self.finishedDownload = true
			self.yuno.saveImageWithKey("Image", image: self.detailImageView.image!, key: self.postUrl)
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
				if let img = self.yuno.fetchImageWithKey("Image", key: self.postUrl){
					imageInfo.image = img
				}
				else if let img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.postUrl){
					if self.yuno.checkFullsSizeWithKey(self.postUrl){
						imageInfo.image = img
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
			imageInfo.referenceView = self.detailImageView.superview
			
			self.imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: [.Blurred, .Scaled])
			self.imageViewer.interactionsDelegate = self
			
			imageViewer.showFromViewController(self, transition: .FromOriginalPosition)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	func getHtml(url : String){
		let manager : AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
		manager.responseSerializer = AFHTTPResponseSerializer()
		
		manager.GET(url, parameters: nil,
			success: {(operation, responseObject) -> Void in
				
				let html : NSString = NSString(data: responseObject as! NSData, encoding: NSASCIIStringEncoding)!
				self.parse(html as String)
				
			}, failure: {(operation, error) -> Void in
				print ("Error : \(error)")
		})
	}
	
	func parse(htmlString : String){
		if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
			for div in doc.css("div#right-col"){
				let img = div.css("img")[1]
				downloadImg(img["src"]!)
				return
			}
		}
	}
	
	func downloadImg(url : String){
		self.urlStr = url
		let imageInfo = JTSImageInfo()
		imageInfo.referenceRect = self.detailImageView.frame
		imageInfo.referenceView = self.detailImageView.superview
		
		if let img = self.yuno.fetchImageWithKey("Image", key: self.postUrl){
			imageInfo.image = img
		}
		else if let img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.postUrl){
			if self.yuno.checkFullsSizeWithKey(self.postUrl){
				imageInfo.image = img
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
		
		let saveAction = UIAlertAction(title: "Save Image", style: .Default, handler: {(alert : UIAlertAction) -> Void in
			UIImageWriteToSavedPhotosAlbum(image, self, Selector("imageSaved:didFinishSavingWithError:contextInfo:"), nil)
		})
		
		let favoriteAction = UIAlertAction(title: "Favorite", style: .Default, handler: {(alert : UIAlertAction) -> Void in
			self.stared()
		})
		
		let unfavoriteAction = UIAlertAction(title: "Unfavorite", style: .Default, handler: {(alert : UIAlertAction) -> Void in
			self.unstared()
		})
		
		let copyAction = UIAlertAction(title: "Copy Image", style: .Default, handler: {(alert : UIAlertAction) -> Void in
			UIPasteboard.generalPasteboard().image = image
			self.alertWithOkButton("Image Copied", message: "This image has been copied to your clipboard")
		})
		
		let copyLinkAction = UIAlertAction(title: "Copy Image URL", style: .Default, handler: {(alert : UIAlertAction) -> Void in
			UIPasteboard.generalPasteboard().string = self.urlStr!
			self.alertWithOkButton("URL Copied", message: "The image URL has been copied to your clipboard")
		})
		
		let openAction = UIAlertAction(title: "Open Post in Safari", style: UIAlertActionStyle.Default, handler: {(alert : UIAlertAction) -> Void in
			UIApplication.sharedApplication().openURL(NSURL(string: "http://konachan.net\(self.postUrl)")!)
		})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
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
			self.alertWithOkButton("Image Saved", message: "This image has been saved to your camera roll")
		})
	}
	
	func alertWithOkButton(title : String?, message : String?){
		dispatch_async(dispatch_get_main_queue(), {
			UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK").show()
		})
	}
}
