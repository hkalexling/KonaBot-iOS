//
//  FavoriteCollectionViewController.swift
//  KonaBot
//
//  Created by Alex Ling on 2/11/2015.
//  Copyright © 2015 Alex Ling. All rights reserved.
//

import UIKit

class FavoriteCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CKManagerNewFavDelegate, KonaHTMLParserDelegate, KonaAPIErrorDelegate, NSURLSessionDownloadDelegate, CloudFavPostDownloadVCDelegate {
	
	let yuno = Yuno()
	
	var favoritePostList : [String] = []
	
	var label : UILabel = UILabel()
	
	var compact : Bool = true
	
	var cellWidth : CGFloat!
	
	var columnNum : Int!
	
	let previewQuility : CGFloat = 2
	
	let ckManager = CKManager()
	
	var newFavUrls : [String] = []
	var newFavPostUrls : [String] = []
	var newFavNum = 0
	var downloadTask : NSURLSessionDownloadTask?
	var favUrlIndex = 0
	
	var favDownloadVC : CloudFavPostsDownloadViewController!
	var downloadDismissed = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Favorite".localized
		self.ckManager.favDelegate = self
    }
	
	override func viewWillAppear(animated: Bool) {
		
		self.ckManager.checkNewFavorited()
		self.compact = NSUserDefaults.standardUserDefaults().integerForKey("viewMode") == 1
		
		if UIDevice.currentDevice().model.hasPrefix("iPad"){
			self.columnNum = 3
		}
		else{
			if CGSize.screenSize().width >= 375 && self.compact {
				self.columnNum = 2
			}
			else{
				self.columnNum = 1
			}
		}
		self.cellWidth = CGSize.screenSize().width/CGFloat(self.columnNum) - 5
		
		let layout : UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
		layout.sectionInset = UIEdgeInsetsMake(0, (CGSize.screenSize().width/CGFloat(self.columnNum) - self.cellWidth)/2, 0, (CGSize.screenSize().width/CGFloat(self.columnNum) - self.cellWidth)/2)
		
		self.favoritePostList = self.yuno.favoriteList()
		self.collectionView!.reloadData()
		
		if (self.favoritePostList.count == 0){
			self.showLabel()
		}
	}
	
	override func viewDidDisappear(animated: Bool) {
		self.label.removeFromSuperview()
	}
	
	func showLabel(){
		let height : CGFloat = 20
		self.label.text = "You haven't favorited any image yet".localized
		self.label.frame = CGRectMake(0, CGSize.screenSize().height/2 - height/2, CGSize.screenSize().width, height)
		self.label.backgroundColor = UIColor.themeColor()
		self.label.textColor = UIColor.konaColor()
		self.label.textAlignment = NSTextAlignment.Center
		self.view.addSubview(self.label)
	}

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.favoritePostList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
		cell.imageView.image = UIImage.imageWithColor(UIColor.placeHolderImageColor())
		dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0), {
			if var img = self.yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[indexPath.row]){
				img = img.resize(cell.imageView.bounds.width * self.previewQuility)
				dispatch_async(dispatch_get_main_queue(), {
					UIView.transitionWithView(cell.imageView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
						cell.imageView.image = img
						}, completion: nil)
				})
			}
		})
		
        return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let detailVC = DetailViewController()
		detailVC.postUrl = self.favoritePostList[indexPath.row]
		let frame = collectionView.cellForItemAtIndexPath(indexPath)?.frame
		detailVC.heightOverWidth = frame!.height/frame!.width
		detailVC.smallImage = yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[indexPath.row])
		self.navigationController!.pushViewController(detailVC, animated: true)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		let size = (yuno.fetchImageWithKey("FavoritedImage", key: self.favoritePostList[indexPath.row]))!.size
		let height = self.cellWidth * (size.height / size.width)
		return CGSizeMake(self.cellWidth, height)
	}
	
	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		self.collectionView!.reloadData()
	}
	
	func CKManagerDidFoundNewFavPost(ids: [String]) {
		if ids.count == 0 {
			return
		}
		dispatch_async(dispatch_get_main_queue(), {
			let konaAlertVC = KonaAlertViewController(backgroundView: self.tabBarController!.view, baseColor: UIColor.themeColor(), secondaryColor: UIColor.konaColor(), dismissButtonColor: UIColor.konaColor())
			self.tabBarController!.addChildViewController(konaAlertVC)
			self.tabBarController!.view.addSubview(konaAlertVC.view)
			konaAlertVC.showAlert("New Favorited Posts found".localized, message: "new-fav-post-alert-before-count".localized + " \(ids.count) " + "new-fav-post-alert-after-count".localized, badChoiceTitle: "No, thanks".localized, goodChoiceTitle: "Yes".localized, badChoiceHandler: {
				konaAlertVC.dismiss()
				}, goodChoiceHandler: {
					konaAlertVC.removeFromParentViewController()
					konaAlertVC.view.removeFromSuperview()
					
					self.downloadDismissed = false
					
					self.favDownloadVC = CloudFavPostsDownloadViewController(backgroundVC: self.tabBarController!, color: UIColor.konaColor(), delegate: self)
					self.favDownloadVC.show()
					self.favDownloadVC.startSpin()
					self.favDownloadVC.setMessage("Getting Post IDs")
					
					let konaParser = KonaHTMLParser(delegate: self, errorDelegate: self)
					self.newFavNum = ids.count
					self.newFavUrls = []
					for id in ids {
						let postUrl = "http://konachan.com/post/show/\(id)/"
						self.newFavPostUrls.append(postUrl)
						konaParser.getPostInformation(postUrl)
					}
			})
		})
	}
	
	func konaAPIGotError(error: NSError) {
		print ("kona api error: \(error)")
	}
	
	func konaHTMLParserFinishedParsing(parsedPost: ParsedPost) {
		self.favDownloadVC.setMessage("Parsing Data From KonaChan")
		self.newFavUrls.append(parsedPost.url)
		if self.newFavUrls.count == self.newFavNum {
			self.favDownloadVC.setMessage("Finished Parsing")
			self.downloadNewFav()
		}
	}
	
	func downloadNewFav() {
		self.favDownloadVC.setMessage("Downloading Image \(self.favUrlIndex + 1)/\(self.newFavNum)")
		self.imageFromUrl(self.newFavUrls[self.favUrlIndex])
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		dispatch_async(dispatch_get_main_queue()){
			print (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
			self.favDownloadVC.stopSpin()
			self.favDownloadVC.setProgress(CGFloat(totalBytesWritten)/(CGFloat)(totalBytesExpectedToWrite))
		}
	}
	
	func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
		
		if self.downloadDismissed {
			return
		}
		
		let downloadedImage = UIImage(data: NSData(contentsOfURL: location)!)!
		dispatch_async(dispatch_get_main_queue()){
			
			Yuno().saveImageWithKey("FavoritedImage", image: downloadedImage, key: self.newFavPostUrls[self.favUrlIndex], skipUpload: true)
			
			self.favUrlIndex += 1
			if self.favUrlIndex < self.newFavNum {
				self.downloadNewFav()
			}
			else{
				self.favoritePostList += self.newFavPostUrls
				let indexPaths = Array(0 ..< self.newFavNum)
					.map({$0 + self.collectionView!.numberOfItemsInSection(0)})
					.map({NSIndexPath(forRow: $0, inSection: 0)})
				self.collectionView!.insertItemsAtIndexPaths(indexPaths)
				self.favDownloadVC.setMessage("Finished")
				self.favDownloadVC.dismiss()
				self.label.removeFromSuperview()
			}
		}
	}
	
	func imageFromUrl(url : String) {
		if let nsUrl = NSURL(string: url){
			let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
			self.downloadTask = session.downloadTaskWithURL(nsUrl)
			self.downloadTask?.resume()
		}
	}
	
	func CloudFavPostDownloadViewControllerWillDismiss() {
		self.downloadTask?.cancel()
		self.newFavUrls = []
		self.newFavPostUrls = []
		self.newFavNum = 0
		self.favUrlIndex = 0
		self.downloadDismissed = true
	}
}
